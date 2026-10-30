package jobs

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/tiagogcastro/aws-iac-blueprint/applications/fileflow/internal/files"
)

type Message struct {
	Job           files.ProcessingJob
	ReceiptHandle string
}

type Queue struct {
	client   *sqs.Client
	queueURL string
}

func NewQueue(client *sqs.Client, queueURL string) *Queue {
	return &Queue{client: client, queueURL: queueURL}
}

func (q *Queue) Publish(ctx context.Context, job files.ProcessingJob) error {
	body, err := json.Marshal(job)
	if err != nil {
		return err
	}
	_, err = q.client.SendMessage(ctx, &sqs.SendMessageInput{
		QueueUrl: aws.String(q.queueURL), MessageBody: aws.String(string(body)),
	})
	return err
}

func (q *Queue) Receive(ctx context.Context) (*Message, error) {
	result, err := q.client.ReceiveMessage(ctx, &sqs.ReceiveMessageInput{
		QueueUrl: aws.String(q.queueURL), MaxNumberOfMessages: 1, WaitTimeSeconds: 20,
	})
	if err != nil || len(result.Messages) == 0 {
		return nil, err
	}
	var job files.ProcessingJob
	if err := json.Unmarshal([]byte(aws.ToString(result.Messages[0].Body)), &job); err != nil {
		return nil, fmt.Errorf("decode processing job: %w", err)
	}
	return &Message{Job: job, ReceiptHandle: aws.ToString(result.Messages[0].ReceiptHandle)}, nil
}

func (q *Queue) Delete(ctx context.Context, receiptHandle string) error {
	_, err := q.client.DeleteMessage(ctx, &sqs.DeleteMessageInput{
		QueueUrl: aws.String(q.queueURL), ReceiptHandle: aws.String(receiptHandle),
	})
	return err
}
