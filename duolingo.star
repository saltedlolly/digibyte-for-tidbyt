"""
Applet: Duolingo 
Summary: Track language progress
Description: Display Duolingo stats and track your progress towards a daily XP target.
Author: Olly Stedall @saltedlolly
"""

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
DUO_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAACXBIWXMAAAsTAAALEwEAmpwYAAABlUlEQVQ4jaWUMXITQRBF399SFccALmKJmKV2RpcgpnwO51wCzagkx8icwqFibmACPsH0jNak3minZ/v3/7+7V7Z5yzO9KRvQ/8e5JAtzykfBjd1ckuNznfcVMBg2r6BsZNjlIz4ki4AQfEqVS0mMoITwSoJhPiQTdXe5tO8wu6UwvHIrLRvTGUitOrBLhXuBbZQnMNxPcU7iZ80B29CmUR6whNG6GgRYu1/RjZxNFI94e3nwhDDffr1DmIc7NZbddTUjZJh68peSLAJNcKkJPb/g5z88HRMKg5GZu8HqbZSYfywRFHJc2nhQ1FAOcNpXqTNqiMJqRhoh33zp0gNnHB73VdOQpKBo2C2Fba6hubVxu5TbyPjGR/MhWzJjAMZcGQZ7hf5o56ojmzFtjnFYdXm7VBA81dTi3bVgKsR02pcWFZxz0bh368Sl5ijXPDrn2shInPfl1txYBYT4XJL7sqh3QeKUqySz/gNseqKHcnP6XTFm+tpE/f2OkZgieb3CYw6EuV6vfmWmutYwkDYgHz+8V9/Kf2R75tl4Ngj0AAAAAElFTkSuQmCC
""")

# 16 x 18
DUO_ICON_FLY_WING_UP = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAAXNSR0IArs4c6QAAAdpJREFUOE9tVLFxGzEQ3PtEJThlBS7BrwJIEWDkDqRcchW2FEslKDABSmRMclyBK7Bid+DAf5q9wwP/HiMg/4HD3u7e3Qu4BIDak61VCvoad8LN8Wi5DXrYZGk7Hsvz2Vpto17GjGMK5TKRBdw7p4DXTRIHbb8Vavk9KE/7sINAcUzR/vuQDeS8C1AF9ptc2cnIn3hLy55wKwLVAQ/oTNpdpxhU8aCCY47YVxYzCYJlCnoZMr6I0/42uMi7IvSrKk454hCTRZgHNEcgpm21DdrHXTFUcfvjwp7vP/0BivJTIoNssZaGD60Sgj4mEPCUAl6ef1px1p8/gsz4cqIPpKUkpw3A0IyqH/L95TfNA64+rCFaCjotuQglRGPAyzoWpwSTSQNWKMU6PlgOnlsV2DhqG75IlxjnHPx9ne3SOUcoW8kSoPbE6CfcUM9guZnN+blNheUhsiNLFaaSVimqyXAE9Gv3YGwgYX9AsY9spNp/HsxLFGFyRheLqX7GOF72GZkDlDoOT6rdNYQNVeJrqxGcmYdH1e6mzVAbpsLi75Nod20j4TWp6YHhEeVy2/dZmARN5cxnbj7Izex/PgfV1Ikv0+/CWJNaheqlKN5+vVV3/idhNG6xWIw9i3cSI/hAZ0IAIAAAAABJRU5ErkJggg==
""")

# 16 x 18
DUO_ICON_FLY_WING_DOWN = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAACXBIWXMAAAsTAAALEwEAmpwYAAABoUlEQVQ4jW2TTW7bMBCFvycY6CGy8Ql6hNbZOzWZS7R7nyPbNrmEKMHZx0IPUvgg9euCP6JRDyCCA828mXmPI9tUk8TTGI3MKc4CI8DAfgwWAtDpObWcDXdsF2Y8BudkA2IXJ5YUciFW6KFP3I/BKKc8xlRSYRcS1THYHcRNB0LsQuIosA1xAMNxAPuKDuJjivSj3XTgMnXjpVYtvpX9mvwfByqBLx4Ac/z9CQwvXwRSA81FrgAMkpDEtym60SNYpgg/H/CvB5Y5IIwMktmn0KTbFP1w+blMsVQBP/4pRT9zTnl2tHZaFWkaW4UcV5aVaVCGsYVU5rc5xaQNXYAK8GNIWLBMIct4mDB5LGNU2JSE9mO05CyMV4ZVnNyt6qQdQOGgSeI+IOd8PUwALHO4AeptOD0nVXFPcVLmIlc+z4HzHNsDMOY9zj2KNu6g/SYPMWmfgjPb5CPvEO9x1vXVPnStqN/GQeLvmzx8t9prl9uzu77i4Qd6GuPag+32VWG1Knzn5OZ+swvQFVS/c+vy1OR270e4XC7NuTdCte12qxrzD6wF41KmxN1hAAAAAElFTkSuQmCC
""")

DUO_ICON_CRY = base64.decode("""
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

def get_schema():

    return schema.Schema(
    version = "1",
    fields = [
        schema.Text(
            id = "duo_username",
            name = "Username",
            desc = "Enter a Duolingo username.",
            icon = "cog",
            default = DEFAULT_USERNAME,
        ),
        schema.Text(
            id = "xp_target",
            name = "Daily XP",
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
    duo_username = config.get("duo_username", DEFAULT_USERNAME)
    xp_target = config.get("xp_target", DEFAULT_DAILY_XP_TARGET)
    display_username_toggle = config.bool("display_username_toggle", DEFAULT_SHOW_USERNAME)

    # Setup user cache keys
    duo_cache_key_username = "duolingo_%s" % duo_username
    duo_cache_key_userid = "%s_userid" % duo_cache_key_username
    duo_cache_key_xpsummary = "%s_xpsummary" % duo_cache_key_username
    duo_cache_key_saveddate = "%s_saveddate" % duo_cache_key_username
    duo_cache_key_totalxp = "%s_saveddate" % duo_cache_key_username

    # Get Cache variables
    duo_userid_cached = cache.get(duo_cache_key_userid)
    duo_xpsummary_cached = cache.get(duo_cache_key_xpsummary)
    duo_saveddate_cached = cache.get(duo_cache_key_saveddate)
    duo_totalxp_cached = cache.get(duo_cache_key_totalxp)

    # Get time and location variables
    timezone = config.get("timezone", DEFAULT_TIMEZONE)

    #Setup account query url
    duolingo_query_url_prefix = "https://www.duolingo.com/2017-06-30/users?username="
    if duo_username != None:
        duolingo_query_url =  duolingo_query_url_prefix + duo_username

    # Setup xp summary query URL
    duo_xpsummary_query_1 = "https://www.duolingo.com/2017-06-30/users/"
    duo_xpsummary_query_2 = "/xp_summaries?startDate="
    duo_xpsummary_query_3 = "&endDate="
    duo_xpsummary_query_4 = "&timezone="

    # Example Query: https://www.duolingo.com/2017-06-30/users/xp_summaries?startDate=2022-02-24&endDate=2022-02-24&Europe/London


    # LOOKUP CURRENT DUOLINGO USERID (OR RETRIEVE FROM CACHE)
    # If the userid for the provided username is not yet known, a query is sent to duolingo.com to retrieve it
    # Thereafter the userid is cached for 7 days, and the timer is updated on each run


    # Check a username has been provided (i.e. field is not blank)
    if duo_username != None:
        # Check if the userId is already known, otherwise perform a query to look it up
        if duo_userid_cached == None:
            do_duolingo_query = True
        else:
            do_duolingo_query = False
            print("Getting userId from cache.")
            duo_userid = duo_userid_cached
            print("Cached userId for username " + duo_username + ": " + duo_userid)
            # update userid cache timer
            cache.set(duo_cache_key_userid, duo_userid, ttl_seconds=604800)
            display_error_msg = False
    else:
        print("Error! No Duolingo username provided.")
        display_error_msg = True
        error_message_1 = "No username provided."

    # Lookup userId from supplied username (if not already found in cache)
    if do_duolingo_query == True:
        print("Querying duolingo.com for userId...")
        duolingo_query = http.get(duolingo_query_url)
        if duolingo_query.status_code != 200:
            print("Duolingo query failed with status %d", duolingo_query.status_code)
            display_error_msg = True
            error_message = "Error: Duolingo query failed. Check internet connectivity."
        else:
            duo_userid = str(duolingo_query.json()["users"][0]["id"])
            # Show error if username was not recognised
            if duo_userid == "":
                print("userId query failed with status %d", duolingo_query.status_code)
                display_error_msg = True
                error_message_1 = "Username is unrecognised."
            else:
                display_error_msg = False
                print("Queried userId for username \"" + str(duo_username) + "\": " + str(duo_userid))
                cache.set(duo_cache_key_userid, str(duo_userid), ttl_seconds=604800)


    #RESET CACHE DURING TESTING
    # cache.set(duo_cache_key_userid, '', ttl_seconds=604800)


    # If we know the userId then get the progress data for that user (either from duolingo or from cache)

    if duo_userid != None:

        # LOOKUP XP SUMMARY
        # The XP summary is updated every 15 minutes

        # Get today's date
        now = time.now().in_location(timezone)
        date_now = now.format("2006-01-02").upper()


        # Get the date 6 days ago
        six_days_ago = now - time.parse_duration("144h") 
        startDate = six_days_ago.format("2006-01-02").upper()

        # Set end date variable (today)
        endDate = date_now

        print("Today's Date: " + str(endDate) + "   Date 6 days ago: " + str(startDate))

        DUO_XP_QUERY_URL = duo_xpsummary_query_1 + str(duo_userid) + duo_xpsummary_query_2 + startDate + duo_xpsummary_query_3 + endDate + duo_xpsummary_query_4 + timezone

        if duo_xpsummary_cached != None:
            print("Hit! Displaying cached XP summary data.")
            duo_xpsummary = duo_xpsummary_cached
        else:
            print("Miss! Querying duolingo for XP summary data.")
            xpsummary_query = http.get(DUO_XP_QUERY_URL)
            if xpsummary_query.status_code != 200:
                print("XP summary query failed with status %d", xpsummary_query.status_code)
                display_error_msg = True
                error_message = "Error: XP Summary query failed. Check internet connectivity."
            else:
                display_error_msg = False
                duo_xpsummary = xpsummary_query.json()
                # Show error if username was not recognised
                print("XP Summary returned.")
                cache.set(duo_cache_key_xpsummary, str(duo_xpsummary), ttl_seconds=14400)


        # LOOKUP DUOLINGO ACCOUNT DATA AT START OF DAY
        # The is performed daily to get the total XP (the first time the script runs after today's date changes)

        # Run this if today's date has changed (or this is the first time running)
        if (duo_saveddate_cached != date_now):
            print("New day!")
            # First we are going to get the totalXp score at the start of the day (we will use this to calculate the running total throughout the day)
            if do_duolingo_query == True:
                duo_totalxp = int(duolingo_query.json()["users"][0]["totalXp"])
            else:
                # Setup userid query URL
                print("Querying duolingo.com for totalXp...")
                duolingo_query = http.get(duolingo_query_url)
                if duolingo_query.status_code != 200:
                    print("Duuolingo query failed with status %d", duolingo_query.status_code)
                    display_error_msg = True
                    error_message = "Error: Duuolingo query failed. Check internet connectivity."
                else:
                    duo_totalxp = int(duolingo_query.json()["users"][0]["totalXp"])
                    # Show error if totalxp was not found
                    if duo_totalxp == "":
                        print("totalXp query failed with status %d", duolingo_query.status_code)
                        display_error_msg = True
                        error_message = "Error: totalXp not found."
                    else:
                        display_error_msg = False
                        print("Queried totalXp for username \"" + str(duo_username) + "\": " + str(duo_totalxp))
 #                       cache.set(duo_cache_key_totalxp, str(duo_totalxp), ttl_seconds=86400)

            # Next find out the XP achieved already today (in case some XP was already gained today before this ran i.e. after midnight)

            # Get the today's XP count
            duo_xptoday = int(duo_xpsummary.json()["summaries"][0]["gainedXp"])
            print("XP Today: " + duo_xptoday)

            # Finally update the cache with the new date so this won't run again until tomorrow



    # DISPLAY ERROR MESSAGES
    # If the data queries failed in any way, then show an error on the Tidbyt

    if display_error_msg == True:
        print("ERROR! No duolingo data available!")
        display_output = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Image(src = DUO_ICON_CRY),

                    # Column to hold pricing text evenly distrubuted accross 1-3 rows
                    render.Column(
                        main_align = "space_evenly",
                        expanded = True,
                        children = render.Column(
                            cross_align = "center",
                            children = [
                                render.Text("ERROR:", font = "CG-pixel-3x5-mono", color = "#FF0000"),
                                render.Text("%s" % error_message_1, font = "CG-pixel-3x5-mono"),
#                                render.Text("%s" % error_message_2, font = "CG-pixel-3x5-mono"),
                            ],
                        ),
                    ),
                ],
            ),
        )




    return render.Root(
        child = display_output,
    )


