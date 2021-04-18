// Code generated by smithy-go-codegen DO NOT EDIT.

package ec2

import (
	"context"
	awsmiddleware "github.com/aws/aws-sdk-go-v2/aws/middleware"
	"github.com/aws/aws-sdk-go-v2/aws/signer/v4"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/aws/smithy-go/middleware"
	smithyhttp "github.com/aws/smithy-go/transport/http"
)

// Creates an Amazon EBS-backed AMI from an Amazon EBS-backed instance that is
// either running or stopped. If you customized your instance with instance store
// volumes or EBS volumes in addition to the root device volume, the new AMI
// contains block device mapping information for those volumes. When you launch an
// instance from this new AMI, the instance automatically launches with those
// additional volumes. For more information, see Creating Amazon EBS-Backed Linux
// AMIs
// (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html)
// in the Amazon Elastic Compute Cloud User Guide.
func (c *Client) CreateImage(ctx context.Context, params *CreateImageInput, optFns ...func(*Options)) (*CreateImageOutput, error) {
	if params == nil {
		params = &CreateImageInput{}
	}

	result, metadata, err := c.invokeOperation(ctx, "CreateImage", params, optFns, addOperationCreateImageMiddlewares)
	if err != nil {
		return nil, err
	}

	out := result.(*CreateImageOutput)
	out.ResultMetadata = metadata
	return out, nil
}

type CreateImageInput struct {

	// The ID of the instance.
	//
	// This member is required.
	InstanceId *string

	// A name for the new image. Constraints: 3-128 alphanumeric characters,
	// parentheses (()), square brackets ([]), spaces ( ), periods (.), slashes (/),
	// dashes (-), single quotes ('), at-signs (@), or underscores(_)
	//
	// This member is required.
	Name *string

	// The block device mappings. This parameter cannot be used to modify the
	// encryption status of existing volumes or snapshots. To create an AMI with
	// encrypted snapshots, use the CopyImage action.
	BlockDeviceMappings []types.BlockDeviceMapping

	// A description for the new image.
	Description *string

	// Checks whether you have the required permissions for the action, without
	// actually making the request, and provides an error response. If you have the
	// required permissions, the error response is DryRunOperation. Otherwise, it is
	// UnauthorizedOperation.
	DryRun bool

	// By default, Amazon EC2 attempts to shut down and reboot the instance before
	// creating the image. If the No Reboot option is set, Amazon EC2 doesn't shut down
	// the instance before creating the image. When this option is used, file system
	// integrity on the created image can't be guaranteed.
	NoReboot bool

	// The tags to apply to the AMI and snapshots on creation. You can tag the AMI, the
	// snapshots, or both.
	//
	// * To tag the AMI, the value for ResourceType must be
	// image.
	//
	// * To tag the snapshots that are created of the root volume and of other
	// EBS volumes that are attached to the instance, the value for ResourceType must
	// be snapshot. The same tag is applied to all of the snapshots that are
	// created.
	//
	// If you specify other values for ResourceType, the request fails. To
	// tag an AMI or snapshot after it has been created, see CreateTags
	// (https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateTags.html).
	TagSpecifications []types.TagSpecification
}

type CreateImageOutput struct {

	// The ID of the new AMI.
	ImageId *string

	// Metadata pertaining to the operation's result.
	ResultMetadata middleware.Metadata
}

func addOperationCreateImageMiddlewares(stack *middleware.Stack, options Options) (err error) {
	err = stack.Serialize.Add(&awsEc2query_serializeOpCreateImage{}, middleware.After)
	if err != nil {
		return err
	}
	err = stack.Deserialize.Add(&awsEc2query_deserializeOpCreateImage{}, middleware.After)
	if err != nil {
		return err
	}
	if err = addSetLoggerMiddleware(stack, options); err != nil {
		return err
	}
	if err = awsmiddleware.AddClientRequestIDMiddleware(stack); err != nil {
		return err
	}
	if err = smithyhttp.AddComputeContentLengthMiddleware(stack); err != nil {
		return err
	}
	if err = addResolveEndpointMiddleware(stack, options); err != nil {
		return err
	}
	if err = v4.AddComputePayloadSHA256Middleware(stack); err != nil {
		return err
	}
	if err = addRetryMiddlewares(stack, options); err != nil {
		return err
	}
	if err = addHTTPSignerV4Middleware(stack, options); err != nil {
		return err
	}
	if err = awsmiddleware.AddRawResponseToMetadata(stack); err != nil {
		return err
	}
	if err = awsmiddleware.AddRecordResponseTiming(stack); err != nil {
		return err
	}
	if err = addClientUserAgent(stack); err != nil {
		return err
	}
	if err = smithyhttp.AddErrorCloseResponseBodyMiddleware(stack); err != nil {
		return err
	}
	if err = smithyhttp.AddCloseResponseBodyMiddleware(stack); err != nil {
		return err
	}
	if err = addOpCreateImageValidationMiddleware(stack); err != nil {
		return err
	}
	if err = stack.Initialize.Add(newServiceMetadataMiddleware_opCreateImage(options.Region), middleware.Before); err != nil {
		return err
	}
	if err = addRequestIDRetrieverMiddleware(stack); err != nil {
		return err
	}
	if err = addResponseErrorMiddleware(stack); err != nil {
		return err
	}
	if err = addRequestResponseLogging(stack, options); err != nil {
		return err
	}
	return nil
}

func newServiceMetadataMiddleware_opCreateImage(region string) *awsmiddleware.RegisterServiceMetadata {
	return &awsmiddleware.RegisterServiceMetadata{
		Region:        region,
		ServiceID:     ServiceID,
		SigningName:   "ec2",
		OperationName: "CreateImage",
	}
}
