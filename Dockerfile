FROM ubuntu:16.04
RUN apt-get -qq update
RUN apt-get -q -y install git-core git-svn ruby
RUN gem install svn2git
CMD ["svn2git"]
