# Sample Canvas API
This sample provides a minimal example to demonstrate how to create a custom API for Canvas.  There are two files in the repo
* **manage_events.rb**: API script
* **Sample API_boomerang.json**: A boomerang project file for testing the API

## Chrome Setup
The **chrome** boomerang plugin is used to test the API.  This plugin works similar to postman.  Install the plugin here:
* **chrome boomerang plugin**: https://chrome.google.com/webstore/detail/boomerang-soap-rest-clien/eipdnjedkpcnlmmdfdkgfpljanehloah?hl=en

Once the plugin is installed, load the `.json` boomerang project file

## Script Setup
Place the script file in `lib/api` (the `api` directory will need to be created) and restart Canvas.  Functions in the script are available at: 
* **script urls**: http://hostname:port/api/script_name/function_name

All functions require the http `post` verb.

The sample script has the following urls:
* **create_event**: http://hostname:port/api/manage_events/create_event
* **cancel_event**: http://hostname:port/api/manage_events/cancel_event
* **delete_event**: http://hostname:port/api/manage_events/delete_event

See the boomerang project file for sample paylaods.  The sample uses json payloads but other formats (such as XML) can be used.

## Error Handling
If an error occurs, the API returns a message in the following format:
```json
{
  "status": "error",
  "error_message": "Detailed error message"
}
```

Most errors will be from a database query not finding a required piece of information (such as a market context or a VEN).

Another source of errors will be not setting a required field or providing an invalid value to a field.  ActiveRecord validations will catch many of these errors when the record is saved, and an error message indicating the invalid field is provided.

## Tips for modfying the API
The APIs interact directly with the database through ActiveRecord.  An overview of active record can be found here: https://guides.rubyonrails.org/active_record_basics.html

The ActiveRecord models can be found in `app/models`.  The top of the files contains a list of fields avaialble in that model.  The top of the class definition includes a list of relationships (has_many for one to many, and belongs_to for one to one).  These relationships guide what additional objects need to be created when creating itmes such as events.

## Production APIs
This API is provided as an example only and is not intended for production use.  There are two key pieces missing from the sample:
* authoriziation checks
* unit tests

We are working on documentation for creating production-ready APIs.  In the meantime, please contact us at contact@gridfabric.io for help getting started on a production API.
