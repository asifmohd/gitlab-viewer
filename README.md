## Notes about this branch
This branch includes an oauth implementation instead of the personal access token approach on master.

To try this out:
- create an app under Gitlab settings for your user.
- Set the callback url to be "gitlabvieweroauth://oauthsuccess"
- Let the scope of the application be `api`
- Go to the app settings flow, by clicking on the gear icon in the top right of the app's home screen
- Copy paste the application id, secret, and callback url from the above newly registered app on gitlab
- Set the instance url to your self hosted gitlab instance or the `https://gitlab.com` instance
- Click on connect, login to your instance, and when the popup shows up asking to open Gitlab Viewer, click on Open.
- At this point, you should be able to view the groups and runner info

Caveats:
- The current implementation does not use the [refresh tokens](https://docs.gitlab.com/ee/api/oauth2.html#web-application-flow) provided as part of the oauth callback flow.
  - Hence the token will expire in 120 mins generally. At which point, you can use the app settings flow described above, once more to generate a new token

To do:
- [ ] Give user an option in the app settings, to either select the personal access token flow, or the oauth token flow
  - Initial idea: add a segmented control, to toggle between the two flows. Anda accept the instance id along with personal access token as part of a form.
  - This would ideally allow me to merge the changes in this branch to master, and support both auth mechanisms
- [ ] Use the refresh token from the above API, to refresh the bearer token automatically on every app launch if required.
- [ ] Move the tokens to be stored in keychain instead of user defaults right now

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
