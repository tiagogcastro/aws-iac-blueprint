package cloud

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

type Clients struct {
	S3       *s3.Client
	DynamoDB *dynamodb.Client
	SQS      *sqs.Client
}

func New(ctx context.Context, region, endpoint string) (Clients, error) {
	configuration, err := awsconfig.LoadDefaultConfig(ctx, awsconfig.WithRegion(region))
	if err != nil {
		return Clients{}, fmt.Errorf("load AWS configuration: %w", err)
	}

	return Clients{
		S3: s3.NewFromConfig(configuration, func(options *s3.Options) {
			options.UsePathStyle = endpoint != ""
			options.RequestChecksumCalculation = aws.RequestChecksumCalculationWhenRequired
			options.ResponseChecksumValidation = aws.ResponseChecksumValidationWhenRequired
			setEndpoint(&options.BaseEndpoint, endpoint)
		}),
		DynamoDB: dynamodb.NewFromConfig(configuration, func(options *dynamodb.Options) {
			setEndpoint(&options.BaseEndpoint, endpoint)
		}),
		SQS: sqs.NewFromConfig(configuration, func(options *sqs.Options) {
			setEndpoint(&options.BaseEndpoint, endpoint)
		}),
	}, nil
}

func setEndpoint(target **string, endpoint string) {
	if endpoint != "" {
		*target = aws.String(endpoint)
	}
}
