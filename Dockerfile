FROM ruby:3 AS build
COPY . /app
WORKDIR /app
RUN bundle install \
    && jekyll build


FROM nginx:1-alpine AS final
COPY --from=build /app/_site /usr/share/nginx/html
