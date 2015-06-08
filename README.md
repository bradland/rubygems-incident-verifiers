# Gem validation for gem owners #

**Please only perform these steps if you are the Gem owner.**

##Summary

The tools provided here enable you to check local copies of your gem to the copies present on Rubygems.org. These tools are intended for gem developers to check their local dev copies against the Rubygems.org server (why? see note at end of doc).

There are a few verification efforts going on right now:

1. Verify against mirrors (close to complete)
2. Users verify their local gems against rubygems (there are sepaerate scripts for this)
3. Gem owners verify against Rubygems.org (you're about to learn how)

As a gem owner, you can help us out by verifying your local .gem file against the .gem file in the Rubygems.org S3 bucket. This process is optional, but it helps us rebuild trust in Rubygems.org, so we'd appreciate any effort you can contribute.

Before you begin, please note that there are TWO ways to accomplish this. The first only works if you have the *original* .gem file you published to the Rubygems.org website. If not, please look ahead to the second option.

## Option 1 - I have my original .gem file ##

If you have a copy of the original .gem file that you pushed to rubygems.org, you can verify a checksum of both files.

**IMPORTANT!** The checksum method will fail if you are not using the *exact* same .gem file originally submitted to Rubygems.org. That is expected.

You should read the script you're about to run. You can view the formatted source by clicking the file `hash_comparison_validation_of_gem.rb` here in the Github repo, then follow these steps.

Fire up a terminal and cd to the `pkg/` directory where you build your gem, or whatever other location you store your gem packages. Then:

    wget https://raw.github.com/bradland/rubygems-incident-verifiers/master/hash_comparison_validation_of_gem.rb
    chmod u+x hash_comparison_validation_of_gem.rb

You can now run the validator against your gem files. If you were validating a gem named `gemfile-0.0.0.gem`, you'd do the following.

    hash_comparison_validation_of_gem.rb gemfile-0.0.0.gem

The script will output the result of comparison beetween a hash of your gem file, and provide an overall pass/fail for the comparison.

If you encounter a "fail", please try the additional verification method listed under Option 2. After review, submit your results in the [Google Form][form] if you feel action is required.


## Option 2 - I do NOT have my original .gem file ##

If you do not have your original .gem file, you'll need you to verify the contents of the .gem hosted on Rubygems.org S3 and a .gem file built locally.

You should read the script you're about to run. You can view the formatted source by clicking the file `file_by_file_validation_of_gem.rb` here in the Github repo, then follow these steps.

Fire up a terminal and cd to the `pkg/` directory where you build your gem, or whatever other location you store your gem packages. Then:

    wget https://raw.github.com/bradland/rubygems-incident-verifiers/master/file_by_file_validation_of_gem.rb
    chmod u+x file_by_file_validation_of_gem.rb

You can now run the validator against your gem files. If you were validating a gem named `gemfile-0.0.0.gem`, you'd do the following.

    file_by_file_validation_of_gem.rb gemfile-0.0.0.gem

The script will output the result of comparison beetween each file in your gem, and provide an overall pass/fail for the comparison.

If you encounter a "fail", please review the contents of the mismatched files. After review, submit your results in the [Google Form][form] if you feel action is required.

[form]:https://docs.google.com/forms/d/1ww3Icilk2U2VsULv64-27Wz2yHXMAteuUdlfjaqtkAs/viewform

## Contributors ##

Thanks to @cowboyd and @revans for contributing the scripts.

## Why all this? ##

The Rubygems.org server was compromised by a remote code vulnerability exploit. Details available at official Rubygems sources.
