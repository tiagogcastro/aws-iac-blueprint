package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/files"
)

type DynamoDB struct {
	client      *dynamodb.Client
	filesTable  string
	eventsTable string
}

func NewDynamoDB(client *dynamodb.Client, filesTable, eventsTable string) *DynamoDB {
	return &DynamoDB{client: client, filesTable: filesTable, eventsTable: eventsTable}
}

func (d *DynamoDB) CreateFile(ctx context.Context, file files.File) error {
	item, err := attributevalue.MarshalMap(file)
	if err != nil {
		return fmt.Errorf("encode file: %w", err)
	}
	_, err = d.client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: aws.String(d.filesTable), Item: item,
		ConditionExpression: aws.String("attribute_not_exists(id)"),
	})
	return err
}

func (d *DynamoDB) GetFile(ctx context.Context, id string) (files.File, error) {
	result, err := d.client.GetItem(ctx, &dynamodb.GetItemInput{
		TableName: aws.String(d.filesTable),
		Key:       map[string]types.AttributeValue{"id": &types.AttributeValueMemberS{Value: id}},
	})
	if err != nil {
		return files.File{}, err
	}
	if len(result.Item) == 0 {
		return files.File{}, files.ErrNotFound
	}
	var file files.File
	if err := attributevalue.UnmarshalMap(result.Item, &file); err != nil {
		return files.File{}, fmt.Errorf("decode file: %w", err)
	}
	return file, nil
}

func (d *DynamoDB) ListFiles(ctx context.Context, ownerID string, limit int32) ([]files.File, error) {
	result, err := d.client.Query(ctx, &dynamodb.QueryInput{
		TableName: aws.String(d.filesTable), IndexName: aws.String("owner-created-at-index"),
		KeyConditionExpression:   aws.String("owner_id = :owner"),
		FilterExpression:         aws.String("#status <> :deleted"),
		ExpressionAttributeNames: map[string]string{"#status": "status"},
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":owner":   &types.AttributeValueMemberS{Value: ownerID},
			":deleted": &types.AttributeValueMemberS{Value: files.StatusDeleted},
		},
		ScanIndexForward: aws.Bool(false), Limit: aws.Int32(limit),
	})
	if err != nil {
		return nil, err
	}
	var list []files.File
	if err := attributevalue.UnmarshalListOfMaps(result.Items, &list); err != nil {
		return nil, fmt.Errorf("decode files: %w", err)
	}
	return list, nil
}

func (d *DynamoDB) UpdateStatus(ctx context.Context, id, status, sha256 string) error {
	values := map[string]types.AttributeValue{
		":status":  &types.AttributeValueMemberS{Value: status},
		":updated": &types.AttributeValueMemberS{Value: time.Now().UTC().Format(time.RFC3339Nano)},
	}
	expression := "SET #status = :status, updated_at = :updated"
	if sha256 != "" {
		expression += ", sha256 = :sha"
		values[":sha"] = &types.AttributeValueMemberS{Value: sha256}
	}
	_, err := d.client.UpdateItem(ctx, &dynamodb.UpdateItemInput{
		TableName:                 aws.String(d.filesTable),
		Key:                       map[string]types.AttributeValue{"id": &types.AttributeValueMemberS{Value: id}},
		UpdateExpression:          aws.String(expression),
		ExpressionAttributeNames:  map[string]string{"#status": "status"},
		ExpressionAttributeValues: values,
		ConditionExpression:       aws.String("attribute_exists(id)"),
	})
	return err
}

func (d *DynamoDB) AddEvent(ctx context.Context, event files.Event) error {
	item, err := attributevalue.MarshalMap(event)
	if err != nil {
		return fmt.Errorf("encode event: %w", err)
	}
	_, err = d.client.PutItem(ctx, &dynamodb.PutItemInput{TableName: aws.String(d.eventsTable), Item: item})
	return err
}

func (d *DynamoDB) ListEvents(ctx context.Context, fileID string) ([]files.Event, error) {
	result, err := d.client.Query(ctx, &dynamodb.QueryInput{
		TableName:              aws.String(d.eventsTable),
		KeyConditionExpression: aws.String("file_id = :id"),
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":id": &types.AttributeValueMemberS{Value: fileID},
		},
		ScanIndexForward: aws.Bool(false),
	})
	if err != nil {
		return nil, err
	}
	var events []files.Event
	if err := attributevalue.UnmarshalListOfMaps(result.Items, &events); err != nil {
		return nil, fmt.Errorf("decode events: %w", err)
	}
	return events, nil
}
