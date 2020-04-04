## Gitlab Viewer

An iOS app which lists the groups, projects and merge requests for a gitlab instance by accepting a configurable base url and auth token.

I wanted to try out SwiftUI on a demo project, and I have to use Gitlab everyday at my day job. So I thought let's try building a Gitlab client.

And I have to say, it's a lot of fun building with SwiftUI, the views are so composable.

The current flow of the app is as follows:

- List all Groups you have access to
  - Show all Projects in that group with pagination support
    - Show All the Merge Requests in that project


### Why host a gitlab client on github 😅?

This GitHub profile contains most of my public code, so it made sense to me to open source on GitHub instead of Gitlab.

### Configuration

- Do a git clone of this repo

- Create a `.gitlab-configs.yml` file in the root of this project, with these keys

    `BASE_URL: <insert_your_gitlab_instance_base_url_with_api_v4_appended>`
    `AUTH_TOKEN: <insert_your_personal_access_token>`

   A run script in the `Gitlab Viewer` target will try to read from `.gitlab-configs.yml` file and copy the credentials to the build directory's `Gitlab_configs.plist`

- Build and run the app

### Requirements
- Built with Xcode 11.4
- Minimum deployment target is iOS 13.0
