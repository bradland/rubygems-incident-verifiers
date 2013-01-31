# Info for gem owners

**Please only perform these steps if you are the Gem owner.**

##Summary

The tools provided here enable you to check local copies of your gem to the copies present on Rubygems.org. These tools are intended for gem developers to check their local dev copies against the Rubygems.org server.

There are a few verification efforts going on right now:

1. Verify against mirrors (close to complete)
2. Users verify their local gems against rubygems (there are sepaerate scripts for this)
3. Gem owners verify against Rubygems.org (you’re about to learn how)

As a gem owner, you can help us out by verifying your local .gem file against the .gem file in the Rubygems.org S3 bucket. This process is optional, but it helps us rebuild trust in Rubygems.org, so we’d appreciate any effort you can contribute.

Before you begin, please be note that there are TWO ways to accomplish this. The first only works if you have the *original* .gem file you published to the Rubygems.org website. If not, please look ahead to the second option.

## I have my original .gem file

If you have a copy of the original .gem file that you pushed to rubygems.org, you can verify a checksum of both files.

* Use the validate_original_gem.sh script to verify your local gem package against Rubygems.org
* If you encounter a mismatch, please post results to this Google Form

#### Scripts needed (IN WORK by revans):

**Compare gem to Rubygems.org hashes**

Script can be written in Ruby or bash. Compare hash of local .gem (passed as arg) to Rubygems.org .gem hash list.

Invocation: `file_by_file_validation_of_gem.rb ./path/to/gemfile.gem`

Returns: 

    Gem compared: <gemname-0.0.0.gem>
      Remote hash: <hash>
      Local hash:  <hash>
    Overall result: [PASS|FAIL]

The script should:

* Grab the hash list from either/or
    * Rubygems (MD5): http://cl.ly/MY8P
    * Rubygems (SHA512): http://cl.ly/MYie
    * Script should prefer SHA512 if possible
* Use basename of ARGV[0] to lookup gem hash
    * Err if not found
* Display the hashes for each
* Indicate an overall pass/fail
    * PASS on match between both hashes
    * FAIL on mismatch
* If FAIL, suggest that they revisit this doc to use the unpack script (below)

## I do NOT have my original .gem file

If you do not have your original .gem file, we’ll need you to verify the contents of the .gem hosted on Rubygems.org S3 and a .gem file built locally.

* Use the validate_original_gem_unpack.sh script to verify your local gem contents against Rubygems.org
* If you encounter a mismatch, please review the contents of the mismatched files
* After review, submit your results in the Google Form

#### Scripts needed (IN WORK by cowboyd):

Script can be written in Ruby or bash. Compare contents of unpacked local .gem to unpacked Rubygems.org S3 .gem.

Invocation: `validate_original_gem_unpack.sh ./path/to/gemfile.gem`

Returns:

    Files compared:
      path/to/file1.ext - [pass|fail]
      path/to/file2.ext - [pass|fail]
      path/to/file3.ext - [REMOTE ORPHAN]
    Overall result: [PASS|FAIL]

The script should: 

* Download the matching .gem from S3
    * Use basename from ARGV[0] to build S3 gem path
        * S3 gem path: http://production.cf.rubygems.org/gems/<basename>
    * Err if remote file not found
* Unpack S3 .gem file
    * Err if unable to unpack (some corrupt gems exist on S3)
* Unpack .gem file from ARGV[0]
* Iterate over files in .gem file from S3
    * Report pass/fail based on SHA512 comparison of corresponding files
    * Report remote orphans (files that exist in S3 gem, but not locally)
* Report an overall pass/fail
    * PASS on all checksums matched AND no orphans found
    * FAIL on checksum mismatch OR orphan found
