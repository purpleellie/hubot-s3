# Description:
#   Queries for the status of AWS services
#
# Dependencies:
#	aws-sdk
#
# Configuration:
#   HUBOT_AWS_ACCESS_KEY_ID
#   HUBOT_AWS_SECRET_ACCESS_KEY
#   HUBOT_AWS_SQS_REGIONS
#   HUBOT_AWS_EC2_REGIONS
#
# Commands:
#   hubot list buckets - Returns the list of s3 buckets
#
# Author:
#   Andrew Quitadamo

key = process.env.HUBOT_S3_ACCESS_KEY_ID
secret = process.env.HUBOT_S3_SECRET_ACCESS_KEY

aws = require 'aws-sdk'
aws.config.region = 'us-east-1'
aws.config.update({accessKeyId: key, secretAccessKey: secret})

s3 = new aws.S3()

module.exports = (robot) ->	
	robot.respond /list buckets/i, (msg) ->
       s3.listBuckets (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            buckets = data.Buckets
            for bucket in buckets
                msg.send "#{bucket.Name} : #{bucket.CreationDate}"
