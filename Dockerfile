FROM ruby:2.7.0

## nodejsとyarnはwebpackをインストールする際に必要
# yarnパッケージ管理ツールをインストール
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

RUN apt-get update -qq && apt-get install -y nodejs yarn
RUN mkdir /apps
WORKDIR /apps
COPY Gemfile /apps/Gemfile
COPY Gemfile.lock /apps/Gemfile.lock
RUN gem update --system 
RUN bundle install
#RUN rails new . --force --no-deps --dafabase=mysql --skip-bundle
COPY ./apps /apps
RUN bundle install
RUN yarn install --check-files
RUN bundle exec rails webpacker:compile
#RUN rake db:create

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]