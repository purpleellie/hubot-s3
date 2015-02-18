# Configuration:
#   HUBOT_AWS_ACCESS_KEY_ID
#   HUBOT_AWS_SECRET_ACCESS_KEY
#
# Commands:
#   hubot create bucket <name> [<acl settings> <region>] - Returns the list of s3 buckets
#   hubot list buckets - List all buckets
#   hubot delete bucket <name> - Deletes bucket
#   hubot get bucket policy <name> - Gets the bucket's policy
#   hubot delete bucket policy <name> - Deletes the bucket's policy
#   hubot set bucket policy <name> <policy> - Set the bucket's policy to given policy
#   hubot delete object <bucket> <object> - Delete object from a bucket
#   hubot get bucket location <bucket> - Get AWS region of a bucket
#   hubot list objects <bucket> - List all the objects in a bucket
#   hubot list buckets - Lists all buckets
#
#
# Author:
#   Andrew Quitadamo

#TODO: Ask to delete
#TODO: Fix undefined in list objects
#TODO: Add tests

key = process.env.HUBOT_S3_ACCESS_KEY_ID
secret = process.env.HUBOT_S3_SECRET_ACCESS_KEY

aws = require 'aws-sdk'
aws.config.update({accessKeyId: key, secretAccessKey: secret})

s3 = new aws.S3()

module.exports = (robot) ->
    robot.respond /create bucket ([\w.+\-]+) ([\w.+\-]+) ([\w.+\-]+)/i, (msg) ->
#msg.send "Hello There"
        bucketName = msg.match[1]
        acl = msg.match[2]
        config = msg.match[3]
        if acl==""
            acl="private"
        params =
            Bucket: bucketName
            ACL: acl
            CreateBucketConfiguration:
                LocationConstraint: config
        s3.createBucket params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            msg.send "#{bucketName} was successfully created\n#{data.Location}"

    robot.respond /delete bucket ([\w.+\-]+)/i, (msg) ->
        bucketName =  msg.match[1]
        params =
            Bucket: bucketName
        s3.deleteBucket params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            msg.send "#{bucketName} was successfully deleted"
            for key, value of data
                msg.send "#{key} : #{value}"

    robot.respond /get bucket policy ([\w.+\-]+)/i, (msg) ->
        bucketName =  msg.match[1]
        params =
            Bucket: bucketName
        s3.getBucketPolicy params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            msg.send "#{data.Policy}"

    robot.respond /delete bucket policy ([\w.+\-]+)/i, (msg) ->
        bucketName =  msg.match[1]
        params =
            Bucket: bucketName
        s3.deleteBucketPolicy params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            msg.send "Bucket #{bucketName}'s policy was deleted successfully"

    robot.respond /set bucket policy ([\w.+\-]+) (.*)/i, (msg) ->
        bucketName =  msg.match[1]
        bucketPolicy = msg.match[2]
        params =
            Bucket: bucketName
            Policy: bucketPolicy
        s3.putBucketPolicy params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            msg.send "Bucket #{bucketName}'s policy was updated successfully"

    robot.respond /get bucket website ([\w.+\-]+)/i, (msg) ->
        bucketName =  msg.match[1]
        params =
            Bucket: bucketName
        s3.getBucketWebsite params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            index = data.IndexDocument
            msg.send "Index Document: #{index.Suffix}"

    robot.respond /delete object ([\w.+\-]+) ([\w.+\-]+)/i, (msg) ->
        bucketName =  msg.match[1]
        objectName = msg.match[2]
        params =
            Bucket: bucketName
            Key: objectName
        s3.deleteObject params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            msg.send "#{objectName} was deleted successfully"

    robot.respond /get bucket location ([\w.+\-]+)/i, (msg) ->
        bucketName =  msg.match[1]
        params =
            Bucket: bucketName
        s3.getBucketLocation params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            location = data.LocationConstraint
            if location == undefined
                location = "us-east-1"
            msg.send "#{location}"

    robot.respond /list objects ([\w.+\-]+)/i, (msg) ->
        bucketName = msg.match[1]
        params = 
            Bucket: bucketName
        s3.listObjects params, (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            contents = data.Contents
            setInterval ->
                content = contents.pop()
                msg.send "Name: #{content.Key}\nLast Modified: #{content.LastModified}\nSize: #{content.Size}\n\n"
            , 700

    robot.respond /list buckets/i, (msg) ->
       s3.listBuckets (error, data) ->
            if error?
                msg.send "Uh-oh. Something has gone wrong\n#{error}"
                return
            buckets = data.Buckets
            for bucket in buckets
                msg.send "#{bucket.Name} : #{bucket.CreationDate}"
