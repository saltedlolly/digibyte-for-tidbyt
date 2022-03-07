"""
Applet: Duolingo 
Summary: Track language study progress
Description: Display Duolingo stats and track your progress towards a daily XP target.
Author: Olly Stedall @saltedlolly
Thanks: @drudge
"""

################################################################################
# IMPORTANT: This app is still a work in progress and is not yet fully working
################################################################################

print(" ---------------------------------------------------------------------------------------------------------------------")

load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("cache.star", "cache")
load("schema.star", "schema")
load("math.star", "math")
load("time.star", "time")


# 16 x 18
DUOLINGO_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAACXBIWXMAAAsTAAALEwEAmpwYAAABlUlEQVQ4jaWUMXITQRBF399SFccALmKJmKV2RpcgpnwO51wCzagkx8icwqFibmACPsH0jNak3minZ/v3/7+7V7Z5yzO9KRvQ/8e5JAtzykfBjd1ckuNznfcVMBg2r6BsZNjlIz4ki4AQfEqVS0mMoITwSoJhPiQTdXe5tO8wu6UwvHIrLRvTGUitOrBLhXuBbZQnMNxPcU7iZ80B29CmUR6whNG6GgRYu1/RjZxNFI94e3nwhDDffr1DmIc7NZbddTUjZJh68peSLAJNcKkJPb/g5z88HRMKg5GZu8HqbZSYfywRFHJc2nhQ1FAOcNpXqTNqiMJqRhoh33zp0gNnHB73VdOQpKBo2C2Fba6hubVxu5TbyPjGR/MhWzJjAMZcGQZ7hf5o56ojmzFtjnFYdXm7VBA81dTi3bVgKsR02pcWFZxz0bh368Sl5ijXPDrn2shInPfl1txYBYT4XJL7sqh3QeKUqySz/gNseqKHcnP6XTFm+tpE/f2OkZgieb3CYw6EuV6vfmWmutYwkDYgHz+8V9/Kf2R75tl4Ngj0AAAAAElFTkSuQmCC
""")

# 16 x 18
DUOLINGO_ICON_FLY_WING_UP = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAAXNSR0IArs4c6QAAAdpJREFUOE9tVLFxGzEQ3PtEJThlBS7BrwJIEWDkDqRcchW2FEslKDABSmRMclyBK7Bid+DAf5q9wwP/HiMg/4HD3u7e3Qu4BIDak61VCvoad8LN8Wi5DXrYZGk7Hsvz2Vpto17GjGMK5TKRBdw7p4DXTRIHbb8Vavk9KE/7sINAcUzR/vuQDeS8C1AF9ptc2cnIn3hLy55wKwLVAQ/oTNpdpxhU8aCCY47YVxYzCYJlCnoZMr6I0/42uMi7IvSrKk454hCTRZgHNEcgpm21DdrHXTFUcfvjwp7vP/0BivJTIoNssZaGD60Sgj4mEPCUAl6ef1px1p8/gsz4cqIPpKUkpw3A0IyqH/L95TfNA64+rCFaCjotuQglRGPAyzoWpwSTSQNWKMU6PlgOnlsV2DhqG75IlxjnHPx9ne3SOUcoW8kSoPbE6CfcUM9guZnN+blNheUhsiNLFaaSVimqyXAE9Gv3YGwgYX9AsY9spNp/HsxLFGFyRheLqX7GOF72GZkDlDoOT6rdNYQNVeJrqxGcmYdH1e6mzVAbpsLi75Nod20j4TWp6YHhEeVy2/dZmARN5cxnbj7Izex/PgfV1Ikv0+/CWJNaheqlKN5+vVV3/idhNG6xWIw9i3cSI/hAZ0IAIAAAAABJRU5ErkJggg==
""")

# 16 x 18
DUOLINGO_ICON_FLY_WING_DOWN = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAACXBIWXMAAAsTAAALEwEAmpwYAAABoUlEQVQ4jW2TTW7bMBCFvycY6CGy8Ql6hNbZOzWZS7R7nyPbNrmEKMHZx0IPUvgg9euCP6JRDyCCA828mXmPI9tUk8TTGI3MKc4CI8DAfgwWAtDpObWcDXdsF2Y8BudkA2IXJ5YUciFW6KFP3I/BKKc8xlRSYRcS1THYHcRNB0LsQuIosA1xAMNxAPuKDuJjivSj3XTgMnXjpVYtvpX9mvwfByqBLx4Ac/z9CQwvXwRSA81FrgAMkpDEtym60SNYpgg/H/CvB5Y5IIwMktmn0KTbFP1w+blMsVQBP/4pRT9zTnl2tHZaFWkaW4UcV5aVaVCGsYVU5rc5xaQNXYAK8GNIWLBMIct4mDB5LGNU2JSE9mO05CyMV4ZVnNyt6qQdQOGgSeI+IOd8PUwALHO4AeptOD0nVXFPcVLmIlc+z4HzHNsDMOY9zj2KNu6g/SYPMWmfgjPb5CPvEO9x1vXVPnStqN/GQeLvmzx8t9prl9uzu77i4Qd6GuPag+32VWG1Knzn5OZ+swvQFVS/c+vy1OR270e4XC7NuTdCte12qxrzD6wF41KmxN1hAAAAAElFTkSuQmCC
""")

DUOLINGO_ICON_CRY = base64.decode("""
R0lGODlhEAASANUsAI3/AYz/AI3+AQ645uDg4OHg4Iz+AYz+AODg4f+YAYz/Af///wEBAf6YAP+ZAP/BB+Dh4P6ZAf+ZAQEAAf7AB43/ABewyyavqEbXgB+wuSfGuESuYy6vlz6vdD6uczWvhiawqBWwzx6vuUyuUY3+AEyvUE2vUE2uUU2uUE2vUUyuUEyvUf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh/wtYTVAgRGF0YVhNUDw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDcuMS1jMDAwIDc5LmVkYTJiM2ZhYywgMjAyMS8xMS8xNy0xNzoyMzoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDplYjRkMWNlMC1mNzMxLTQ5ZDAtOGQ5MC1iODRmMjMyNGJmNmIiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NDc3QjlFN0U4QUFBMTFFQzkwOTk4MEJEQTNFNEYzNzciIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NDc3QjlFN0Q4QUFBMTFFQzkwOTk4MEJEQTNFNEYzNzciIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjEgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo4ZTZlNTRlMC1lYjk4LTQ3ODAtOGVhMS1mNDliZWYzYzQ5MWEiIHN0UmVmOmRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDoyNzYzNGY1Mi1kMDc5LTViNDAtYTczNi0wNzkzY2IzYmIwNmEiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4B//79/Pv6+fj39vX08/Lx8O/u7ezr6uno5+bl5OPi4eDf3t3c29rZ2NfW1dTT0tHQz87NzMvKycjHxsXEw8LBwL++vby7urm4t7a1tLOysbCvrq2sq6qpqKempaSjoqGgn56dnJuamZiXlpWUk5KRkI+OjYyLiomIh4aFhIOCgYB/fn18e3p5eHd2dXRzcnFwb25tbGtqaWhnZmVkY2JhYF9eXVxbWllYV1ZVVFNSUVBPTk1MS0pJSEdGRURDQkFAPz49PDs6OTg3NjU0MzIxMC8uLSwrKikoJyYlJCMiISAfHh0cGxoZGBcWFRQTEhEQDw4NDAsKCQgHBgUEAwIBAAAh+QQFCgAsACwAAAAAEAASAAAGm0CWcEgsGo/IU4l4QiFTB1RpdQKojqUUSaFSkUiraxFFEggAAAMpsDKuAJOFwsBYBMRElGAwoDz4AidFKiMGFSoJDiEkByYpRGEqYSslJScpKXgsTV0lKpgrI5dEUydrJysHbCqCQ44nIyYoJiMrJp9EsSkXb2wpKMCkLCYgJsbAbW1DypizI06bRxINQgkRSAUEEAUIBNwEBENBACH5BAUKACwALAUACQAFAAcAAAYOQJaQZRkaj8MRctgxBgEAIfkEBQoALAAsBQAIAAUABwAABg5AlpCVGhqFmaPSWDIGAQAh+QQFCgAsACwFAAkABQAHAAAGDkCWkFUaGoWYo9KYMgYBACH5BAUKACwALAkACgABAAMAAAYFwBSLEwQAIfkEBQoALAAsCQALAAEAAwAABgXAA+sTBAAh+QQFCgAsACwFAAgABQAHAAAGDUANa0gsGo/DEXLoCQIAIfkEBQoALAAsBQAJAAUABwAABg1AC2tILBqPwxVyuAkCACH5BAUKACwALAUACAAFAAcAAAYNwAprSCSKisikkoUKAgAh+QQFCgAsACwFAAkABQAHAAAGDcAVa0gkYorIpJI1CgIAIfkEBQoALAAsBQAKAAEAAwAABgVAFesSBAAh+QQFCgAsACwFAAsAAQADAAAGBUAS6xIEADs=
""")


# Streak Icon Flame 7x8
STREAK_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAcAAAAICAYAAAA1BOUGAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAa0lEQVQImUWOwRGCAAwE9xgdWrE5qvGD3WgPPKAUdIb1EYn55TbZBJWzjufYjcrQ4DXKtgOQX9YQAYMP2nUBOOZIhNu15ua3QIb2rB9CMGnv8L8hAll3Tm1tLoIhW4EsBaOSBKd6JEDulX8BRtYybu/wWx4AAAAASUVORK5CYII=
""")

# Crown Icon  9x7
CROWN_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAGCAYAAAARx7TFAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAYElEQVQImWWNwQ3DIAADzygjtMvA/MkuhR24PqgUovrhh235UNllr49AXWavEpij6cTZmwBzVFUKgAE/1bxOSAhib/L7LAAh+L7YOWuRe+RfHRIgKz8AYmA0iCgLdx/xBe0JOsNPUxB6AAAAAElFTkSuQmCC
""")


# Set applet defaults
DEFAULT_USERNAME = "saltedlolly"
DEFAULT_DAILY_XP_TARGET = "100"
DEFAULT_SHOW_USERNAME = True
DEFAULT_TIMEZONE = "Europe/London"

# Display options
displayoptions = [
    schema.Option(
        display = "Day View",
        value = "day",
    ),
#    schema.Option(
#        display = "Week View",
#        value = "week",
#    ),
]

def get_schema():

    return schema.Schema(
    version = "1",
    fields = [
        schema.Text(
            id = "duolingo_username",
            name = "Username",
            desc = "Enter a Duolingo username.",
            icon = "cog",
            default = DEFAULT_USERNAME,
        ),
        schema.Dropdown(
            id = "display",
            name = "Display",
            desc = "Choose Day or Week view.",
            icon = "brush",
            default = displayoptions[0].value,
            options = displayoptions,
        ),
        schema.Text(
            id = "xp_target",
            name = "Daily XP target",
            desc = "Enter a daily XP goal. Note: This goal resets when the app first runs after midnight. If your ",
            icon = "cog",
            default = DEFAULT_DAILY_XP_TARGET,
        ),
        schema.Toggle(
            id = "display_username_toggle",
            name = "Display Username?",
            desc = "Toggle displaying Duolingo username.",
            icon = "toggle-on",
            default = DEFAULT_SHOW_USERNAME,
        ),
    ],
)

def main(config):

    # Get Schema variables
    duolingo_username = config.get("duolingo_username", DEFAULT_USERNAME)
    xp_target = config.get("xp_target", DEFAULT_DAILY_XP_TARGET)
    display_username_toggle = config.bool("display_username_toggle", DEFAULT_SHOW_USERNAME)
#    display_output = displayoptions.get(config.get("display"), displayoptions[0].value)

    # Setup user cache keys
    duolingo_cache_key_username = "duolingo_%s" % duolingo_username
    duolingo_cache_key_userid = "%s_userid" % duolingo_cache_key_username
    duolingo_cache_key_xpsummary_json = "%s_xpsummary_json" % duolingo_cache_key_username
    duolingo_cache_key_main_json = "%s_main_json" % duolingo_cache_key_username
    duolingo_cache_key_saveddate = "%s_saveddate" % duolingo_cache_key_username
    duolingo_cache_key_totalxp_daystart = "%s_totalxp_daystart" % duolingo_cache_key_username

    # Get Cache variables
    duolingo_userid_cached = cache.get(duolingo_cache_key_userid)
    duolingo_xpsummary_json_cached = cache.get(duolingo_cache_key_xpsummary_json)
    duolingo_main_json_cached = cache.get(duolingo_cache_key_main_json)
    duolingo_saveddate_cached = cache.get(duolingo_cache_key_saveddate)
    duolingo_totalxp_daystart_cached = cache.get(duolingo_cache_key_totalxp_daystart)

    # Get time and location variables
    timezone = config.get("timezone", DEFAULT_TIMEZONE)

    #Setup main query url
    duolingo_main_query_url_prefix = "https://www.duolingo.com/2017-06-30/users?username="
    if duolingo_username != None:
        duolingo_main_query_url =  duolingo_main_query_url_prefix + duolingo_username


    # !!!!!!!!!! TROUBLESHOOTING !!!!! USED DURING TESTING - WILL RESET THE CACHED USERID TO FORCE TO A NEW QUERY
#    duolingo_userid_cached = None
#    duolingo_saveddate_cached = None


    # IMPORTANT NOTE: There are two queries that need to be made to duolingo.com
    # The main query is made the first time the script runs each day (to update the daily xptotal)
    # The xpsummary query is made every 15 minutes (to get the running xp count, and live status)


    # FIRST LOOKUP CURRENT DUOLINGO USERID (OR RETRIEVE FROM CACHE)
    # If the userid for the provided username is not yet known, send a query to duolingo.com to retrieve it
    # Thereafter the userid for the associated username is cached for 7 days, and the timer is updated on each run
    # i.e. So as long as that username continues to be used in the app, the userid will remain cached


    # Check a username has been provided (i.e. field is not blank)
    if duolingo_username != None:
        # Check if the userId is already known, otherwise perform a query to look it up
        if duolingo_userid_cached == None:
            do_duolingo_main_query = True
        else:
            do_duolingo_main_query = False
            duolingo_userid = duolingo_userid_cached
            print("Cached userId for username " + duolingo_username + ": " + duolingo_userid)
            # update userid cache timer
            cache.set(duolingo_cache_key_userid, duolingo_userid, ttl_seconds=604800)
            display_error_msg = False
    else:
        print("Error! No Duolingo username provided.")
        display_error_msg = True
        error_message_1 = "Username is"
        error_message_2 = "blank."

    # Lookup userId from supplied username (if not already found in cache)
    if do_duolingo_main_query == True:
        print("Querying duolingo.com for userId...")
        duolingo_main_query = http.get(duolingo_main_query_url)
        if duolingo_main_query.status_code != 200:
            print("Duolingo query failed with status %d", duolingo_main_query.status_code)
            display_error_msg = True
            error_message = "Error: Duolingo query failed. Check internet connectivity."
        else:
            # display an error message if the username is unrecognised
            duolingo_main_json = duolingo_main_query.json()
            if duolingo_main_json["users"] == []:
                print("Error! Unrecognised username.")
                display_error_msg = True
                error_message_1 = "ERROR: username"
                error_message_2 = "is unrecognised."
                duolingo_userid = None
            else:
                duolingo_userid = int(duolingo_main_json["users"][0]["id"])
                if duolingo_userid != None:
                    print("Success! userId for username \"" + str(duolingo_username) + "\": " + str(duolingo_userid))
                    cache.set(duolingo_cache_key_userid, str(duolingo_userid), ttl_seconds=604800)
                    display_error_msg = False
                else:
                    # Show error if username not found
                    print("userId not found.")
                    display_error_msg = True
                    error_message_1 = "Username not found."

    


    # If we know the userId then next we'll lookup the progress data for that user (either from duolingo or from cache)
    if duolingo_userid != None:

        # LOOKUP DUOLINGO XP SUMMARY JSON DATA
        # The XP summary is updated every 15 minutes

        # Example Query: https://www.duolingo.com/2017-06-30/users/xp_summaries?startDate=2022-02-24&endDate=2022-02-24&Europe/London

        # Setup xp summary query URL
        duolingo_xpsummary_query_1 = "https://www.duolingo.com/2017-06-30/users/"
        duolingo_xpsummary_query_2 = "/xp_summaries?startDate="
        duolingo_xpsummary_query_3 = "&endDate="
        duolingo_xpsummary_query_4 = "&timezone="


        # Get today's date
        now = time.now().in_location(timezone)
        date_now = now.format("2006-01-02").upper()


        # Get the date 6 days ago
        six_days_ago = now - time.parse_duration("144h") 
        startDate = six_days_ago.format("2006-01-02").upper()

        # Set end date variable (today)
        endDate = date_now

        print("Today's Date: " + str(endDate) + "   Date 6 days ago: " + str(startDate))

        DUOLINGO_XP_QUERY_URL = duolingo_xpsummary_query_1 + str(duolingo_userid) + duolingo_xpsummary_query_2 + startDate + duolingo_xpsummary_query_3 + endDate + duolingo_xpsummary_query_4 + timezone

        if duolingo_xpsummary_json_cached != None:
            duolingo_xpsummary_json = json.decode(duolingo_xpsummary_json_cached)
            print("XP summary data retrieved from cache.")
            live_xp_data = False
        else:
            print("Querying duolingo.com for XP summary data.")
            xpsummary_query = http.get(DUOLINGO_XP_QUERY_URL)
            if xpsummary_query.status_code != 200:
                print("XP summary query failed with status %d", xpsummary_query.status_code)
                display_error_msg = True
                error_message_1 = "XP Summary query failed."
                error_message_2 = "Check internet connection."
                live_xp_data = None
            else:
                display_error_msg = False
                duolingo_xpsummary_json = xpsummary_query.json()
                live_xp_data = True
                # Show error if username was not recognised
                print("XP summary data retrieved from duolingo.com")
                cache.set(duolingo_cache_key_xpsummary_json, json.encode(duolingo_xpsummary_json), ttl_seconds=900)

        # Now we get today's daily XP count from the xpsummary_query_json variable (which updates with live data every 15 mins)
        # We'll need this below, to calculate the total XP earned
        duolingo_xptoday = int(duolingo_xpsummary_json["summaries"][0]["gainedXp"])


        # LOOKUP DUOLINGO MAIN JSON DATA AT START OF DAY
        # The is run daily to calculate what the user's totalXP was at the start of the day
        # It runs whenever it detects that the date has changed sicne the previous run

        # Run this if today's date has changed and live data has just been retried (or this is the first time running)
        if (duolingo_saveddate_cached != date_now) and (live_xp_data == True):
            print("New day detected!")

            # First we are going to get the totalXp score at the start of the day 
            # (we will use this to calculate the running XP total throughout the day)
            if do_duolingo_main_query == True:
                duolingo_totalxp = int(duolingo_main_json["users"][0]["totalXp"])
            else:
                # Setup userid query URL
                print("Querying duolingo.com for current totalXp...")
                duolingo_main_query = http.get(duolingo_main_query_url)
                if duolingo_main_query.status_code != 200:
                    print("Duolingo query failed with status %d", duolingo_main_query.status_code)
                    display_error_msg = True
                    error_message = "Error: Duolingo query failed. Check internet connectivity."
                else:
                    duolingo_main_json = duolingo_main_query.json()
                    duolingo_totalxp = int(duolingo_main_json["users"][0]["totalXp"])
                    
                    # Show error if totalxp was not found
                    if duolingo_totalxp == "":
                        print("totalXp query failed with status %d", duolingo_main_query.status_code)
                        display_error_msg = True
                        error_message = "Error: totalXp not found."
                    else:
                        display_error_msg = False
                        print("Queried totalXp for username \"" + str(duolingo_username) + "\": " + str(duolingo_totalxp))
 #                       cache.set(duolingo_cache_key_totalxp, str(duolingo_totalxp), ttl_seconds=86400)


            # Now we subtract the daily XP count from the total count to find out the XP count at the start of the day
            # (this is saved in the cache so we don't have to continue do the main json query throughout the day - we can calculate the)
            # running live total by adding the XP at start of day to the current daily count from the XP Summary query.)
            duolingo_totalxp_daystart = int(duolingo_totalxp) - int(duolingo_xptoday)

            print("XP Count at Start of Day: " + str(duolingo_totalxp_daystart))

            # Store start-of-day XP count in cache (for 24hrs)
            cache.set(duolingo_cache_key_totalxp_daystart, str(duolingo_totalxp_daystart), ttl_seconds=86400)


            # Finally update the cache with the new date so this won't run again until tomorrow (stored for 24 hours)
            cache.set(duolingo_cache_key_saveddate, str(date_now), ttl_seconds=86400)



        # Set variables for current state
        if live_xp_data == True:
            print("---- CURRENT DATA: LIVE ----- ")
        elif live_xp_data == False:
            print("---- CURRENT DATA: CACHED ----- ")
        elif live_xp_data == None:
            print("---- CURRENT DATA: UNAVAILABLE ----- ")

        # Use cached value for current Total XP if live value is not available
        if duolingo_totalxp_daystart_cached != None:
            duolingo_totalxp_daystart = str(duolingo_totalxp_daystart_cached)

        # Calculate current total XP
        duolingo_totalxp_now = int(duolingo_totalxp_daystart) + int(duolingo_xptoday)
        print("Today's XP: " + str(duolingo_xptoday) + "  Start of Day: " + str(duolingo_totalxp_daystart) + "   TOTAL XP: " + str(duolingo_totalxp_now))

        is_frozen = bool(duolingo_xpsummary_json["summaries"][0]["frozen"])
        print("Frozen?: " + str(is_frozen))

        is_streak_extended = bool(duolingo_xpsummary_json["summaries"][0]["streakExtended"])
        print("Streak Extended?: " + str(is_streak_extended))



    # DISPLAY ERROR MESSAGES
    # If the data queries failed in any way, then show an error on the Tidbyt

    if display_error_msg == True:
        display_output = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Image(src = DUOLINGO_ICON_CRY),

                    # Column to hold pricing text evenly distrubuted accross 1-3 rows
                    render.Column(
                        main_align = "space_evenly",
                        expanded = True,
                        children = render.Column(
                            cross_align = "center",
                            children = [
                                render.Text("ERROR:", font = "CG-pixel-3x5-mono", color = "#FF0000"),
                                render.Text("%s" % error_message_1, font = "CG-pixel-3x5-mono"),
                                render.Text("%s" % error_message_2, font = "CG-pixel-3x5-mono"),
                            ],
                        ),
                    ),
                ],
            ),
        )




    return render.Root(
          child = []
#        child = display_output,
    )


