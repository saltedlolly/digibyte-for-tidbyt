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

# Set applet defaults
DEFAULT_USERNAME = "saltedlolly"
DEFAULT_DAILY_XP_TARGET = "100"       # Choose the desired daily XP goal. The XP goal set in the Duolingo app is ignored.
DEFAULT_TIMEZONE = "Europe/London"    # Affects when the daily XP counter resets.
DEFAULT_DISPLAY_VIEW = "today"        # can be 'today', 'week' or 'twoweeks'
DEFAULT_NICKNAME = "Olly"             # Max five characters. Displays on screen to identify the Duolingo user.
DEFAULT_SHOW_NICKNAME = False         # Choose whther to display the nickname on screen.
DEFAULT_SHOW_EXTRA_STATS = True       # Display currennt Streak and total XP score on the week chart.


# 16 x 18
DUOLINGO_ICON_STANDING = base64.decode("""
UklGRh4CAABXRUJQVlA4WAoAAAASAAAADwAAEQAAQU5JTQYAAAD/////AABBTk1G9AAAAAAAAAAAAA8AABEAAIgTAAJWUDhM2wAAAC8PQAQQ/6CQkSSpBmR5lvcQDuNoXgmDbCP1/VUe4lleZGzaSJLkjhbGQlr+2eJ47nr+ywC4q2lQLAe1YYjo30RAGYjaSRA/bYxbNohAUBsEHESSpEj9zLCHAz0z/nU+v4KI/k8A/pLyEHxlU1lxshfp/VDamtUzHRfLaV4s7y/YL5fztFwOL7Lv7utV6wd7ItZ63e/kfhc+pNKozFJVAGkhVKV7kQmIqLZB5d6KZihhVakkzVMjLMop0gZJC00DCY9MWgXS8ZSRro43D1tgt3l1PZ9O59PxdjkBAABBTk1GJgAAAAAAAAAAAAAAAAAAAJCwAAJWUDhMDQAAAC8AAAAQBxAREYiI/gcAQU5NRiwAAAACAAACAAAGAAABAAD0AQAAVlA4TBMAAAAvBkAAEA8w/8M4AfMf8BiziP6HAEFOTUYsAAAAAgAAAwAABgAAAAAALAEAAFZQOEwTAAAALwYAABAPMP/DOAHzH/CoWUT/AwBBTk1GLAAAAAIAAAMAAAYAAAAAACwBAABWUDhMEwAAAC8GAAAQDzD/8z//8x/wqFlE/wMAQU5NRiwAAAACAAACAAAGAAABAAAMCgAAVlA4TBQAAAAvBkAAEBcw//M///MfgIchieh/MFJJRkboAAAAV0VCUFZQOEzbAAAALw9ABBD/oJCRJKkGZHmW9xAO42heCYNsI/X9VR7iWV5kbNpIkuSOFsZCWv7Z4njuev7LALiraVAsB7VhiOjfREAZiNpJED9tjFs2iEBQGwQcRJKkSP3MsIcDPTP+dT6/goj+TwD+kvIQfGVTWXGyF+n9UNqa1TMdF8tpXizvL9gvl/O0XA4vsu/u61XrB3si1nrd7+R+Fz6k0qjMUlUAaSFUpXuRCYiotkHl3opmKGFVqSTNUyMsyinSBkkLTQMJj0xaBdLxlJGujjcPW2C3eXU9n07n0/F2OQEAAA==
""")

# 16 x 18
DUOLINGO_ICON_STANDING_POINT_LEFT = base64.decode("""
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
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
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
""")

# Duolingo Owl Sleeping - Animated Zzz # 16 x 18
DUOLINGO_ICON_SLEEPING = base64.decode("""
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
""")

# Streak Flame Icon - Gold 6x7
STREAK_ICON_GOLD = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAYAAADaxo44AAAACXBIWXMAAAsTAAALEwEAmpwYAAAGeWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuZWRhMmIzZmFjLCAyMDIxLzExLzE3LTE3OjIzOjE5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjMuMSAoTWFjaW50b3NoKSIgeG1wOkNyZWF0ZURhdGU9IjIwMjItMDItMjBUMTc6NDU6MjRaIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMi0wMy0xMlQxMjozOFoiIHhtcDpNZXRhZGF0YURhdGU9IjIwMjItMDMtMTJUMTI6MzhaIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpkZjU1OTY3YS04NTUwLTQ4OTAtYjgyYi1kMzMxZmY1NjkzMWUiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDpmZTgzYjE5Yy1hMDdhLWIzNDctODhiMS0wZWFkYWI4YjhiMjUiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDowZGZjMTU2Yy1mMTlkLTQ5NjItOGFjZS04ZTExYzc3MTRlMmEiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjBkZmMxNTZjLWYxOWQtNDk2Mi04YWNlLThlMTFjNzcxNGUyYSIgc3RFdnQ6d2hlbj0iMjAyMi0wMi0yMFQxNzo0NToyNFoiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMy4xIChNYWNpbnRvc2gpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDphYzYyYzg5OS1hY2RjLTRmMmMtOGJkNy02OWFmODBhZTJkNzUiIHN0RXZ0OndoZW49IjIwMjItMDMtMTJUMTI6MTc6MTFaIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjMuMSAoTWFjaW50b3NoKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZGY1NTk2N2EtODU1MC00ODkwLWI4MmItZDMzMWZmNTY5MzFlIiBzdEV2dDp3aGVuPSIyMDIyLTAzLTEyVDEyOjM4WiIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIzLjEgKE1hY2ludG9zaCkiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+bq5RSQAAAF1JREFUCJltjLEVRAAUBGe9d+jENacaketGDwJKkRjBR3Qbzu5OVP7mKVTOGQECNO9g6cWg4lOoEOH7gaVTJSr+mlIMLQayHfVIyZCCr4pVMGQvmJVSJcERvd+ZyAVgJzcslQ/SGQAAAABJRU5ErkJggg==
""")

# Streak Flame Icon - Gold Animated 6x7
STREAK_ICON_GOLD_ANIMATED = base64.decode("""
UklGRlQDAABXRUJQVlA4WAoAAAASAAAABQAABwAAQU5JTQYAAAD/////AABBTk1GcAAAAAAAAAAAAAUAAAcAAGQAAAJWUDhMWAAAAC8FwAEAb6CQkSSp1p9qIZ47mtEgkLRx/Tv/Ctu2QdLR///i/AfslQBSkMD7moMn5DKeACW1tWZP4QhBDJoQgwhEmJ6em1yOP7tmEf0PgAYLTCpGen/zsxVBTk1GWgAAAAAAAAEAAAUAAAQAAGQAAABWUDhMQgAAAC8FAAEQV0CQbVN/q2OcZhoEkjauf+dfYds2SDr6/1+c/wBwK0igd43nQAIoaiSFOXpRyhMJ2MB5RP8DpDBe+YtBNkFOTUYqAAAAAQAAAQAAAAAAAAAAZAAAAFZQOEwRAAAALwAAAAAHUOD696D/gYjofwAAQU5NRkoAAAABAAAAAAADAAAFAABkAAAAVlA4TDEAAAAvA0ABECcgEEjyp1pjMwFJYv8/h5AgIfn/r2X+A7CzCRiIJDO5jwCiiCCi/8FWzPEAAEFOTUZIAAAAAQAAAAAAAwAABQAAZAAAAFZQOEwwAAAALwNAARAnIBBI8qdaY7P5V9O2AdPNn26/+Q8A7Eg7GGQbOdi7F3iUR/iI/gef0eUAQU5NRl4AAAAAAAAAAAAFAAAGAABkAAAAVlA4TEYAAAAvBYABEE9AkG2z+VPd4jbTEJAk9v9zKGzbBsnw/3t5/gMAdwokrgR6BAioiSQpmvuPGGMnBwEIIMN6RP8DYAMyuibu+4csQU5NRmAAAAAAAAAAAAAFAAAGAABkAAAAVlA4TEcAAAAvBYABEFdAkG1Tf6tjnGYaBJI2rn/nX2HbNkg6+v9fnP8AcCtIoHeN50ACKKptmzrvj5FWqhiKQAzNI/ofAA/EZ+ixf9emDQBBTk1GWgAAAAAAAAEAAAUAAAQAAGQAAABWUDhMQgAAAC8FAAEQV0CQbVN/q2OcZhoEkjauf+dfYds2SDr6/1+c/wBwK0igd43nQAIoaiSFOXpRiQdE8EV+RP8DSmD72slDJ0FOTUZKAAAAAAAAAAAABAAABQAAZAAAAFZQOEwxAAAALwRAARAnIBBI8qdaYzMBSWL/P4eQICH5/69l/gOwswkYiCQzuY8Ekoggov8BC2fgAQBSSUZGZAAAAFdFQlBWUDhMWAAAAC8FwAEAb6CQkSSp1p9qIZ47mtEgkLRx/Tv/Ctu2QdLR///i/AfslQBSkMD7moMn5DKeACW1tWZP4QhBDJoQgwhEmJ6em1yOP7tmEf0PgAYLTCpGen/zsxU=
""")

# Streak Flame Icon - Greyscale 6x7
STREAK_ICON_GREY = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAYAAAAHCAYAAAArkDztAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAWElEQVQImVWOwRHAIAgEl/Sh7diJNqJFWQ40cnk4mAkv9o7ZAUkASKL3fgB4cllrKQ9ukVBKYc4pSZgkxhgCqLUCEBGfKiciPpW7/0J3Pyozo7V2P9p72wsHTjBgL3z97gAAAABJRU5ErkJggg==
""")

# Streak Flame Icon - Frozen 6x7
STREAK_ICON_FROZEN = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAYAAAAICAYAAADaxo44AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAfElEQVQImW2NoQ3DMBRE31kJCPAMlYrMMk0XMe8iHaCk45iYpE1WiEFBLP0Cx6yHTqe7dzIz/skBSAIgJiwmcBJDb8SEBd+8Aeqox4ote+XQACDXw1zg+Tl4vb8A5gCWvbbg0lDBn+fnHDa4zxO50M5Hq7pdJwsecoHg0Q9j8C1TTGG4qQAAAABJRU5ErkJggg==
""")

# XP Spark Icon - Gold  8x7
XP_ICON_GOLD = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAHCAYAAAA1WQxeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAVklEQVQImWWP0RWAIAwDE7bSWWVCHaFwfoDAk/6ll6atAc1KXVSPzg5l2/oZ5qS9JkpJSvAcIyUiA4sLrHqfAgQGTETumv2GUi6vK9y+aNDG8PEqSXoBEck1BaldkuYAAAAASUVORK5CYII=
""")

# XP Spark Icon - Greyscale  8x7
XP_ICON_GREY = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAHCAYAAAA1WQxeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAW0lEQVQImXXOwQ0AIQhE0Y+xEfuwFO9SEt7txMLYE8SYLEdehkHcnRhVdQAzk9iVFwERSae+yRsBiqp6ay2vnHN8zpm9BRBAonfvzRjj/4cbAaqZJa61EnvvAHyjeCYxgniCQwAAAABJRU5ErkJggg==
""")

# Crown Icon  9x7
CROWN_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAAAkAAAAGCAYAAAARx7TFAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAYElEQVQImWWNwQ3DIAADzygjtMvA/MkuhR24PqgUovrhh235UNllr49AXWavEpij6cTZmwBzVFUKgAE/1bxOSAhib/L7LAAh+L7YOWuRe+RfHRIgKz8AYmA0iCgLdx/xBe0JOsNPUxB6AAAAAElFTkSuQmCC
""")


DISPLAY_VIEW_LIST = {
    "Today": "today",
    "One Week": "week",
    "Two Weeks": "twoweeks",
}

def get_schema():

    displayoptions = [
        schema.Option(display = displayv, value = displayv)
        for displayv in DISPLAY_VIEW_LIST
    ]

    return schema.Schema(
    version = "1",
    fields = [
        schema.Text(
            id = "duolingo_username",
            name = "Username",
            desc = "Enter a Duolingo username.",
            icon = "user",
            default = DEFAULT_USERNAME,
        ),
        schema.Dropdown(
            id = "display_view",
            name = "Display",
            desc = "Choose Today or Week view.",
            icon = "rectangle-wide",
            default = displayoptions[0].value,
            options = displayoptions,
        ),
        schema.Text(
            id = "xp_target",
            name = "Daily XP target",
            desc = "Enter a daily XP goal. Resets at midnight.",
            icon = "trophy",
            default = DEFAULT_DAILY_XP_TARGET,
        ),
        schema.Text(
            id = "nickname",
            name = "Nickname",
            desc = "Display on Tidbyt to identify the user. Max 5 letters.",
            icon = "user",
            default = DEFAULT_NICKNAME,
        ),
        schema.Toggle(
            id = "display_nickname_toggle",
            name = "Display Nickname?",
            desc = "Toggle displaying user nickname.",
            icon = "toggle-on",
            default = DEFAULT_SHOW_NICKNAME,
        ),
        schema.Toggle(
            id = "extra_week_stats",
            name = "Extra Week Stats?",
            desc = "Toggle displaying the current Streak and total XP above the Week view chart.",
            icon = "toggle-on",
            default = DEFAULT_SHOW_EXTRA_STATS,
        ),
    ],
)

def main(config):

    # Get Schema variables
    duolingo_username = config.get("duolingo_username", DEFAULT_USERNAME)
    display_view = DISPLAY_VIEW_LIST.get(config.get("display_view"), DEFAULT_DISPLAY_VIEW)
    xp_target = config.get("xp_target", DEFAULT_DAILY_XP_TARGET)
    nickname = config.get("nickname", DEFAULT_NICKNAME)
    display_nickname_toggle = config.bool("display_nickname_toggle", DEFAULT_SHOW_NICKNAME)
    display_extra_stats = config.bool("extra_week_stats", DEFAULT_SHOW_EXTRA_STATS)

    # if xp_target has no value, set it to zero
    if xp_target == "":
        xp_target = 0

    # Trim nickname to only display first five characters
    nickname = nickname[:5].upper()

    # Setup user cache keys
    duolingo_cache_key_username = "duolingo_%s" % duolingo_username

    duolingo_cache_key_userid = "%s_userid" % duolingo_cache_key_username
    duolingo_cache_key_xpsummary_json = "%s_xpsummary_json" % duolingo_cache_key_username
    duolingo_cache_key_main_json = "%s_main_json" % duolingo_cache_key_username
    duolingo_cache_key_saveddate = "%s_saveddate" % duolingo_cache_key_username
    duolingo_cache_key_totalxp_daystart = "%s_totalxp_daystart" % duolingo_cache_key_username
    duolingo_cache_key_streak_daystart = "%s_streak_daystart" % duolingo_cache_key_username
    duolingo_cache_key_xp_query_time = "%s_xp_query_time" % duolingo_cache_key_username

    # Get Cache variables
    duolingo_userid_cached = cache.get(duolingo_cache_key_userid)
    duolingo_xpsummary_json_cached = cache.get(duolingo_cache_key_xpsummary_json)
    duolingo_xp_query_time_cached = cache.get(duolingo_cache_key_xp_query_time)
    duolingo_main_json_cached = cache.get(duolingo_cache_key_main_json)
    duolingo_saveddate_cached = cache.get(duolingo_cache_key_saveddate)
    duolingo_totalxp_daystart_cached = cache.get(duolingo_cache_key_totalxp_daystart)
    duolingo_streak_daystart_cached = cache.get(duolingo_cache_key_streak_daystart)

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

    # Lookup userId from supplied username (if not already found in cache)
    if do_duolingo_main_query == True:
        print("Querying duolingo.com for userId...")
        duolingo_main_query = http.get(duolingo_main_query_url)
        if duolingo_main_query.status_code != 200:
            if duolingo_main_query.status_code == 422:
                print("Error! No Duolingo username provided.")
                display_error_msg = True
                error_message_1 = "username"
                error_message_2 = "is blank"
                duolingo_userid = None
            else:
                print("Duolingo query failed with status %d", duolingo_main_query.status_code)
                display_error_msg = True
                error_message_1 = "check"
                error_message_1 = "connection"
                duolingo_userid = None
        else:
            # display an error message if the username is unrecognised
            duolingo_main_json = duolingo_main_query.json()
            if duolingo_main_json["users"] == []:
                print("Error! Unrecognised username.")
                display_error_msg = True
                error_message_1 = "invalid"
                error_message_2 = "username"
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
                    error_message_1 = "username"
                    error_message_2 = "not found"

    


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
        hour_now = now.hour


        # Get the date 13 days ago
        thirteen_days_ago = now - time.parse_duration("312h") # 312h /108
        startDate = thirteen_days_ago.format("2006-01-02").upper()


        # Set end date variable (today)
        endDate = date_now

        print("Start Date: " + str(startDate) + "   End Date: " + str(endDate))

        DUOLINGO_XP_QUERY_URL = duolingo_xpsummary_query_1 + str(duolingo_userid) + duolingo_xpsummary_query_2 + startDate + duolingo_xpsummary_query_3 + endDate + duolingo_xpsummary_query_4 + timezone

        if duolingo_xpsummary_json_cached != None:
            duolingo_xpsummary_json = json.decode(duolingo_xpsummary_json_cached)

            # Convert xp_query_time string back in to time.time
            xp_query_time = time.parse_time(duolingo_xp_query_time_cached, "Mon, 02 Jan 2006 15:04:05 -0700")

            print("XP summary data retrieved from cache.")
            live_xp_data = False
        else:
            print("Querying duolingo.com for XP summary data.")
            xpsummary_query = http.get(DUOLINGO_XP_QUERY_URL)
            if xpsummary_query.status_code != 200:
                print("XP summary query failed with status %d", xpsummary_query.status_code)
                display_error_msg = True
                error_message_1 = "check"
                error_message_2 = "connection"
                live_xp_data = None
            else:
                display_error_msg = False
                duolingo_xpsummary_json = xpsummary_query.json()
                xp_query_time = now
                live_xp_data = True
                # Show error if username was not recognised
                print("XP summary data retrieved from duolingo.com")
                cache.set(duolingo_cache_key_xpsummary_json, json.encode(duolingo_xpsummary_json), ttl_seconds=900)

                # Format current time into string
                time_now_formatted = now.format("Mon, 02 Jan 2006 15:04:05 -0700")
                print("Time Now (Formatted for cache): " + str(time_now_formatted))
                cache.set(duolingo_cache_key_xp_query_time, str(time_now_formatted), ttl_seconds=900)

        # Lookup the date from the first 'date' value in JSON too see if it is today's data
        time_of_first_entry_unix_time = int(duolingo_xpsummary_json["summaries"][0]["date"])
        time_of_first_entry = time.from_timestamp(time_of_first_entry_unix_time)
        date_of_first_entry = time_of_first_entry.format("2006-01-02")
        

        # Setup dummy data for use on days with no data available
        dummy_data = { "gainedXp": 0, "streakExtended": False, "frozen": False, "repaired": False, "dummyData": True    }

        # If the data is from yesterday, insert today's dummy data into JSON variable. (This will be replaced by the actual data once it becomes available.)
        if date_of_first_entry != date_now:
            duolingo_xpsummary_json["summaries"].insert(0, dummy_data)
            print("Date of the most recent XP data: " + str(date_of_first_entry) + "   (Dummy data has been inserted for today.)")
        else:
            print("Date of the most recent XP data: " + str(date_of_first_entry) + "   (No dummy data needed for today.)")

        # Work out how many days of data is available (this should be 14 unless the user has only just joined Duolingo witin the last 14 days)
        days_returned = len(duolingo_xpsummary_json["summaries"])
        if days_returned >= 14:
            print("Days with data: " + str(days_returned))
        else:
            print("Days with data: " + str(days_returned) + "   (Query returned less than 14 days of data. New Duolingo user?)")

            # insert historical dummy data if less than 14 days of data exists
            days_of_dummy_data_to_add = 14 - days_returned
            for daynum in range(0, days_of_dummy_data_to_add):
                duolingo_xpsummary_json["summaries"].append(dummy_data)
            print("Total days after inserting dummy data:  " + str(len(duolingo_xpsummary_json["summaries"])))

        # if the user only has 7 or less days of data available, and the two week chart view is selected, only display the one week view
        if days_returned <= 7 and display_view == "twoweeks":
            display_view = "week"


        # Now we get today's daily XP count from the xpsummary_query_json variable (which updates with live data every 15 mins)
        # We'll need this below, to calculate the total XP earned
        duolingo_xptoday = duolingo_xpsummary_json["summaries"][0]["gainedXp"]

        # If the current XP score is null convert to integer zero
        if str(duolingo_xptoday) == "null":
            duolingo_xptoday = 0
        else:
            duolingo_xptoday = int(duolingo_xptoday)


        # Get current streak status
        is_streak_extended = bool(duolingo_xpsummary_json["summaries"][0]["streakExtended"])


        # LOOKUP DUOLINGO MAIN JSON DATA AT START OF DAY
        # The is run daily to calculate what the user's totalXP was at the start of the day
        # It runs whenever it detects that the date has changed from the previous time it was run
        # It also requires live XP data to be available (rather than cached data)

        # Run this if today's date has changed and live data has just been retried (or this is the first time running)
        if (duolingo_saveddate_cached != date_now) and (live_xp_data == True):
            print("New day detected!")

            # First we are going to get the totalXp score at the start of the day 
            # (we will use this to calculate the running XP total throughout the day)
            if do_duolingo_main_query == True:
                duolingo_totalxp = int(duolingo_main_json["users"][0]["totalXp"])
                duolingo_streak = int(duolingo_main_json["users"][0]["streak"])
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
                        error_message_1 = "totalXp"
                        error_message_2 = "not found"
                    else:
                        display_error_msg = False
                        print("Queried totalXp for username \"" + str(duolingo_username) + "\": " + str(duolingo_totalxp))
 #                       cache.set(duolingo_cache_key_totalxp, str(duolingo_totalxp), ttl_seconds=86400)

                    # Get current streak
                    duolingo_streak = int(duolingo_main_json["users"][0]["streak"])
                    
                    # Show error if totalxp was not found
                    if duolingo_streak == "":
                        print("Streak query failed with status %d", duolingo_main_query.status_code)
                        display_error_msg = True
                        error_message_1 = "streak"
                        error_message_2 = "not found"
                    else:
                        display_error_msg = False
                        print("Queried Streak for username \"" + str(duolingo_username) + "\": " + str(duolingo_totalxp))
 #                      cache.set(duolingo_cache_key_totalxp, str(duolingo_totalxp), ttl_seconds=86400)


            # Now we subtract the daily XP count from the total count to find out the XP count at the start of the day
            # (this is saved in the cache so we don't have to continue do the main json query throughout the day - we can calculate the)
            # running live total by adding the XP at start of day to the current daily count from the XP Summary query.)
            duolingo_totalxp_daystart = int(duolingo_totalxp) - int(duolingo_xptoday)

            print("XP Count at Start of Day: " + str(duolingo_totalxp_daystart))

            # Store start-of-day XP count in cache (for 24hrs)
            cache.set(duolingo_cache_key_totalxp_daystart, str(duolingo_totalxp_daystart), ttl_seconds=86400)


            # Now we cache the Streak at the start of the day, and store it in the cache
            if is_streak_extended == True:
                duolingo_streak_daystart = int(duolingo_streak) - 1
            else:
                duolingo_streak_daystart = int(duolingo_streak)

            print("Streak at Start of Day: " + str(duolingo_streak_daystart))

            # Store start-of-day XP count in cache (for 24hrs)
            cache.set(duolingo_cache_key_streak_daystart, str(duolingo_streak_daystart), ttl_seconds=86400)

            # Finally update the cache with the new date so this won't run again until tomorrow (stored for 24 hours)
            cache.set(duolingo_cache_key_saveddate, str(date_now), ttl_seconds=86400)



        # Set variables for current state
        if live_xp_data == True:
            print("---- CURRENT DATA: LIVE ----- ")
        elif live_xp_data == False:
            print("---- CURRENT DATA: CACHED ----- ")
        elif live_xp_data == None:
            print("---- CURRENT DATA: UNAVAILABLE ----- ")

        # Use cached value for Total XP at day start if live value is not available
        if duolingo_totalxp_daystart_cached != None:
            duolingo_totalxp_daystart = str(duolingo_totalxp_daystart_cached)

        # Calculate current total XP
        duolingo_totalxp_now = int(duolingo_totalxp_daystart) + int(duolingo_xptoday)
        print("Today's XP: " + str(duolingo_xptoday) + "  Total XP (at day start): " + str(duolingo_totalxp_daystart) + "   TOTAL XP: " + str(duolingo_totalxp_now))

        # Use cached value for Streak at day start if live value is not available
        if duolingo_streak_daystart_cached != None:
            duolingo_streak_daystart = str(duolingo_streak_daystart_cached)

        # Calculate current Streak, based on whther it has already been extended today
        if is_streak_extended == True:
            duolingo_streak_now = int(duolingo_streak_daystart) + 1
        else:
            duolingo_streak_now = int(duolingo_streak_daystart)

        print("Streak: " + str(duolingo_streak_now) + "   Streak Extended?: " + str(is_streak_extended))


        # Deduce what streak icon to display on Today view
        if is_streak_extended == False:
            streak_icon = STREAK_ICON_GREY
        elif is_streak_extended == True:
            streak_icon = STREAK_ICON_GOLD_ANIMATED


        # Deduce what XP icon to display on Today view
        if int(duolingo_xptoday) == 0:
            XP_ICON = XP_ICON_GREY
        else:
            XP_ICON = XP_ICON_GOLD


        # Deduce which Duolingo icon should be displayed right now
        if int(duolingo_xptoday) == 0 and hour_now >= 18:
            DUOLINGO_ICON = DUOLINGO_ICON_CRY
        elif int(duolingo_xptoday) == 0:
            DUOLINGO_ICON = DUOLINGO_ICON_SLEEPING
        elif int(duolingo_xptoday) > 0 and int(duolingo_xptoday) < 40 and int(xp_target) != 0:
            DUOLINGO_ICON = DUOLINGO_ICON_STANDING_POINT_LEFT
        elif int(duolingo_xptoday) >=  40 and int(duolingo_xptoday) <= 60  and int(xp_target) != 0:
            DUOLINGO_ICON = DUOLINGO_ICON_STANDING
        elif int(duolingo_xptoday) >  60 and int(duolingo_xptoday) < 80  and int(xp_target) != 0:
            DUOLINGO_ICON = DUOLINGO_ICON_STANDING
        elif int(duolingo_xptoday) > 80 and int(duolingo_xptoday) < 100 and int(xp_target) != 0:
            DUOLINGO_ICON = DUOLINGO_ICON_STANDING
        elif int(duolingo_xptoday) > 80 and int(duolingo_xptoday) < 100 and int(xp_target) != 0:
            DUOLINGO_ICON = DUOLINGO_ICON_STANDING
        else:
            print("Error: Could not select specific Duolingo icon, so reverting to the default standing icon.")
            DUOLINGO_ICON = DUOLINGO_ICON_STANDING

        # Setup nickname display, if needed
        if display_nickname_toggle == True:
            nickname_today_view = render.Row(
                main_align = "center",
                cross_align = "right",
                expanded = False,
                children = [
                    render.Text(str(nickname), font = "tom-thumb"),
                ],
            )
        else:
            nickname_today_view = None



    # DISPLAY ERROR MESSAGES
    # If the data queries failed in any way, then show an error on the Tidbyt

    if display_error_msg == True:
        print("Displaying Error message on Tidbyt...")

        display_output = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "space_evenly",
                children = [
                    render.Image(src = DUOLINGO_ICON_CRY),

                    # Column to hold pricing text evenly distrubuted accross 1-3 rows
                    render.Column(
                        main_align = "space_evenly",
                        expanded = False,
                        children = [
                            render.Text("ERROR:", font = "CG-pixel-3x5-mono", color = "#FF0000"),
                            render.Text("%s" % error_message_1, font = "tom-thumb"),
                            render.Text("%s" % error_message_2, font = "tom-thumb"),
                        ],
                    ),
                ],
            ),
        )

    # DISPLAY TODAY VIEW
    # Setup dtoay view layout

    if display_error_msg == False and display_view == "today":
        print("Displaying Day View on Tidbyt...")  


        # Setup progress bar. Don't display if XP target in Schema is set to 0.
        if int(xp_target) == 0:
            progressbar = None
        else:
            # Setup progress bar dimensions
            progressbar_total_length = 25
            progressbar_total_height = 3

            # Calculate progress bar color
            if int(duolingo_xptoday) >= int(xp_target):
                progressbar_col = "#feeb3a"
            else:
                progressbar_col = "#666"

            # Calculate current progress bar length
            #   First, Work out percentage progress to target
            progressbar_perc = (int(duolingo_xptoday) / int(xp_target)) * 100
            #   Second, work out the current length the progress bar should be
            progressbar_current_length = int((progressbar_total_length / 100) * progressbar_perc)

            progressbar = render.Row(
                main_align = "space_evenly",
                cross_align = "center", # Controls vertical alignment
                expanded = False,
                children = [
                    render.Box(
                        width=(progressbar_total_length + 2), 
                        height=(progressbar_total_height + 2), 
                        color="#e1e0e0",
                        child = render.Box(
                            width=progressbar_total_length, 
                            height=progressbar_total_height, 
                            color="#000000",
                            child = render.Padding(
                                child = render.Box(
                                    width=progressbar_current_length, 
                                    height=3, 
                                    color=progressbar_col,
                                ),
                                pad=(0, 0, (progressbar_total_length - progressbar_current_length), 0),                 
                            ),
                        ),
                    ),
                    
                ],
            )

        display_output = render.Box(
            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [
                    render.Column(
                        main_align = "space_evenly",
                        cross_align = "left",
                        expanded = True,
                        children = [
                            nickname_today_view,
                            render.Row(
                                main_align = "space_evenly",
                                cross_align = "end", # Controls vertical alignment
                                expanded = False,
                                children = [
                                    render.Image(src = streak_icon),
                                    render.Box( # spacer column
                                        width=2, 
                                        height=2, 
                                        color="#000000",
                                    ),
                                    render.Text(str(duolingo_streak_now), font = "tom-thumb"),
                                ],
                            ),
                            render.Row(
                                main_align = "space_evenly",
                                cross_align = "end", # Controls vertical alignment
                                expanded = False,
                                children = [
                                    render.Image(src = XP_ICON),
                                    render.Text(str(duolingo_xptoday) + "xp", font = "tom-thumb"),
                                ],
                            ),
                        ],
                    ),

                    # Column to hold pricing text evenly distrubuted accross 1-3 rows
                    render.Column(
                        main_align = "center",
                        cross_align = "center", # Controls vertical alignment
                        expanded = True,
                        children = [
                            render.Row(
                                main_align = "space_evenly",
                                cross_align = "end", # Controls vertical alignment
                                expanded = False,
                                children = [
                                    render.Image(src = DUOLINGO_ICON),
                                ],
                            ),
                            progressbar,
                            
                        ],
                    ),
                ],
            ),
        )

    # DISPLAY WEEK VIEW (OR TWO WEEK VIEW)
    # Setup week view layout

    if display_error_msg == False and (display_view == "week" or display_view == "twoweeks"):
        print("Displaying Week View on Tidbyt...")  

        # Setup verticle bar dimensions
        vertbar_total_width = 5

        print("Display Extra Stats: " + str(display_extra_stats))

        if display_extra_stats == True:
            vertbar_total_height = 16
        else:
            vertbar_total_height = 24


        # Put the XP scores for the week into a list called week_xp_scores. The first entry will be  days 13 ago. The last entry will be today.
        week_xp_scores = []
        for daynum in range(0,14):
            day_xp = duolingo_xpsummary_json["summaries"][daynum]["gainedXp"]
            if day_xp == None:
                day_xp = int(0) 
            else:
                day_xp = int(day_xp)
            week_xp_scores.append(day_xp)

        print( "Two Week's XP Scores: " + str(week_xp_scores))

        # Slice the current week's xp scores, if we are only displaying the last week of data
        if display_view == "week":
            week_xp_scores = (week_xp_scores[0:7])
            print( "One Week's XP Scores: " + str(week_xp_scores))

        # Get the highest value from the available daily scores. This is used to setup the upper_chart_value.
        week_xp_scores_sorted = sorted(week_xp_scores)
        week_xp_highest = int(week_xp_scores_sorted[-1])

        print( "Week's Highest XP Score: " + str(week_xp_highest))

        # Set the upper chart value, based on the highest daily score from the last week
        xp_target = int(xp_target)
        if week_xp_highest <= xp_target and xp_target > 0:
            upper_chart_value = xp_target # Set upper chart height to the xp_target if none if the last weeks scores have exceeded it
        elif week_xp_highest > xp_target:
            upper_chart_value = week_xp_highest # Otherwise set the upper_chart_value to be the highest daily xp score from the last two weeks

        week_progress_chart = []
        vertbar_col = []


        # Setup chart display for the past week. Cycles though each day working backwards towards today.
        for daynum in range (6,-1,-1):

            xp_day_score = duolingo_xpsummary_json["summaries"][daynum]["gainedXp"]

            # Set this day's XP score to 0 if it is Null
            if xp_day_score == None:
                xp_day_score = 0

            # Setup vertbar display variables for this day
            if xp_day_score > 0:
                    display_frozen = False
                    display_missed = False
                    display_repaired = False
            else:
                is_frozen = bool(duolingo_xpsummary_json["summaries"][daynum]["frozen"])
                is_repaired = bool(duolingo_xpsummary_json["summaries"][daynum]["repaired"])
                is_streak_extended = bool(duolingo_xpsummary_json["summaries"][daynum]["streakExtended"])
                if daynum != 0 and is_frozen == True:
                    display_frozen = True
                    display_missed = False
                    display_repaired = False
                elif daynum != 0 and is_frozen == False and is_streak_extended == False and is_repaired == False:
                    display_frozen = False
                    display_missed = True
                    display_repaired = False
                elif daynum != 0 and is_frozen == False and is_streak_extended == False and is_repaired == True:
                    display_frozen = False
                    display_missed = False
                    display_repaired = True

            if display_view == "twoweeks":
                xp_day_score_lastweek = duolingo_xpsummary_json["summaries"][daynum + 7]["gainedXp"]

                # Setup this day last week's XP score to 0 if it is Null
                if str(xp_day_score_lastweek) == None:
                    xp_day_score_lastweek = 0

                # Setup vertbar display variables for this day last week
                if xp_day_score_lastweek > 0:
                        display_frozen_lastweek = False
                        display_missed_lastweek = False
                        display_repaired_lastweek = False
                else:
                    is_frozen_lastweek = bool(duolingo_xpsummary_json["summaries"][daynum + 7]["frozen"])
                    is_repaired_lastweek = bool(duolingo_xpsummary_json["summaries"][daynum + 7]["repaired"])
                    is_streak_extended_lastweek = bool(duolingo_xpsummary_json["summaries"][daynum + 7]["streakExtended"])
                    if daynum != 0 and is_frozen == True:
                        display_frozen_lastweek = True
                        display_missed_lastweek = False
                        display_repaired_lastweek = False
                    elif daynum != 0 and is_frozen == False and is_streak_extended == False and is_repaired == False:
                        display_frozen_lastweek = False
                        display_missed_lastweek = True
                        display_repaired_lastweek = False
                    elif daynum != 0 and is_frozen == False and is_streak_extended == False and is_repaired == True:
                        display_frozen_lastweek = False
                        display_missed_lastweek = False
                        display_repaired_lastweek = True


            # Display different shade of color bar if the XP score was not hit
            if int(xp_day_score) >= int(xp_target):
                vertbar_col = "#feea3a"
                vertbar_col_header = "#ea3afe"
            else:
                vertbar_col = "#9e9e9e"
                vertbar_col_header = "#e1e0e0"

            # Same again but for last weeks color bars
            if int(xp_day_score_lastweek) >= int(xp_target):
                vertbar_lastweek_col = "#feea3a"
                vertbar_lastweek_col_header = "#ea3afe"
            else:
                vertbar_lastweek_col = "#3a3a3a"
                vertbar_lastweek_col_header = "#e1e0e0"

            # Calculate this week vertical bar length
            # First, work out percentage progress towards the upper_chart_value
            vertbar_current_perc = (int(xp_day_score) / int(upper_chart_value)) * 100
            # Second, work out the current height the vertical bar should be
            vertbar_current_height = int((vertbar_total_height / 100) * vertbar_current_perc)

            # Calculate last weeks vertical bar length, if it is being displayed
            if display_view == "twoweeks":
                # First, work out percentage progress towards the upper_chart_value
                vertbar_lastweek_perc = (int(xp_day_score_lastweek) / int(upper_chart_value)) * 100
                # Second, work out the current height the vertical bar should be
                vertbar_lastweek_height = int((vertbar_total_height / 100) * vertbar_lastweek_perc)
            else:
                vertbar_lastweek_height = 0

            # Display normal one week proress bar
            oneweek_bar_normal = [

                # This week full size  bar
                render.Box(
                    width=vertbar_total_width, 
                    height=vertbar_total_height, 
                    color="#000000",
                    child = render.Padding(
                        child = render.Box(
                            width=5, 
                            height=vertbar_current_height, 
                            color=str(vertbar_col),

                            child = render.Padding(
                                child = render.Box(
                                    width=5, 
                                    height=1, 
                                    color=str(vertbar_col_header),
                                ),
                                pad=(0, 0, 0, vertbar_current_height - 1),                 
                            ),
                        ),
                        pad=(0, (vertbar_total_height - vertbar_current_height), 0, 0),                 
                    ),
                ),

                # Spacer bar
                render.Box( # spacer column
                    width=1, 
                    height=(vertbar_total_height), 
                    color="#000000",
                ),

            ]

            oneweek_bar_missed = [

                # This week full size  bar
                render.Box(
                    width=vertbar_total_width, 
                    height=vertbar_total_height, 
                    color="#000000",
                    child = render.Padding(
                        child = render.Box(
                            width=5, 
                            height=vertbar_current_height, 
                            color="#000000",
                            child = render.Text("x", color = "#ff0000",),         
                        ),
                        pad=(0, (vertbar_total_height - 6), 0, 0),                 
                    ),
                ),
                
                # Spacer bar
                render.Box( # spacer column
                    width=1, 
                    height=(vertbar_total_height), 
                    color="#000000",
                ),

            ]

            oneweek_bar_frozen = [

                # This week full size  bar
                render.Box(
                    width=vertbar_total_width, 
                    height=vertbar_total_height, 
                    color="#000000",
                    child = render.Padding(
                        child = render.Box(
                            width=5, 
                            height=vertbar_current_height, 
                            color="#000000",
                            child = render.Image(src = STREAK_ICON_FROZEN),             
                        ),
                        pad=(0, (vertbar_total_height - 7), 0, 0),                 
                    ),
                ),
                
                # Spacer bar
                render.Box( # spacer column
                    width=1, 
                    height=(vertbar_total_height), 
                    color="#000000",
                ),

            ]

            # Display normal one week proress bar
            oneweek_bar_repaired = [

                # This week full size  bar
                render.Box(
                    width=vertbar_total_width, 
                    height=vertbar_total_height, 
                    color="#000000",
                    child = render.Padding(
                        child = render.Box(
                            width=5, 
                            height=2, 
                            color=str(vertbar_col),

                            child = render.Padding(
                                child = render.Box(
                                    width=5, 
                                    height=1, 
                                    color=str(vertbar_col_header),
                                ),
                                pad=(0, 0, 0, vertbar_current_height - 1),                 
                            ),
                        ),
                        pad=(0, (vertbar_total_height - vertbar_current_height), 0, 0),                 
                    ),
                ),

                # Spacer bar
                render.Box( # spacer column
                    width=1, 
                    height=(vertbar_total_height), 
                    color="#000000",
                ),

            ]

            twoweeks_bar_thisweek_normal = render.Box(
                width=3, 
                height=(vertbar_total_height), 
                color="#e1e0e0",
                child = render.Box(
                    width=3, 
                    height=vertbar_total_height, 
                    color="#000000",
                    child = render.Padding(
                        child = render.Box(
                            width=3, 
                            height=vertbar_current_height, 
                            color=str(vertbar_col),

                            child = render.Padding(
                                child = render.Box(
                                    width=3, 
                                    height=1, 
                                    color=str(vertbar_col_header),
                                ),
                                pad=(0, 0, 0, vertbar_current_height - 1),                 
                            ),

                        ),
                        pad=(0, (vertbar_total_height - vertbar_current_height), 0, 0),                 
                    ),
                ),
            )

            twoweeks_bar_lastweek_normal = render.Box(
                width=2, 
                height=(vertbar_total_height), 
                color="#e1e0e0",
                child = render.Box(
                    width=2, 
                    height=vertbar_total_height, 
                    color="#000000",
                    child = render.Padding(
                        child = render.Box(
                            width=2, 
                            height=vertbar_lastweek_height, 
                            color=str(vertbar_lastweek_col),
                        ),
                        pad=(0, (vertbar_total_height - vertbar_lastweek_height), 0, 0),                 
                    ),
                ),
            )

            






            # TESTING VARIABLES


            # Choose what to display - bar, frozen icon, missed, blank or flashing progress (used for today)
            if display_view == "week":
                if display_frozen == True:
                    oneweek_bar = oneweek_bar_frozen                        # display the frozen icon
                elif display_missed == True:
                    oneweek_bar = oneweek_bar_missed                        # display the missed day cross icon
                elif display_repaired == True:
                    oneweek_bar = oneweek_bar_repaired                      # display the band aid icon
 #              elif daynum == 0 and xp_day_score == 0:
 #                  oneweek_bar = oneweek_bar_today_flashing_start          # display the flashing progress indicator
 #              elif daynum == 0 and xp_day_score > 0:
 #                  oneweek_bar = oneweek_bar_today_flashing_progress       # display the flashing progress indicator
 #              elif daynum != 0 and xp_day_score > 0:
 #                  oneweek_bar = oneweek_bar_today_flashing_progress       # display the flashing progress indicator
                else:
                    oneweek_bar = oneweek_bar_normal                               # display the normal progress indicator

            if display_view == "twoweeks":
 #               if display_frozen_lastweek == True:
 #                   twoweeks_bar_lastweek = twoweeks_bar_lastweek_frozen                        # display the frozen icon
 #                   twoweeks_bar_thisweek = twoweeks_bar_thisweek_frozen                        # display the frozen icon
 #               elif display_missed_lastweek == True:
 #                   twoweeks_bar_lastweek = twoweeks_bar_lastweek_missed                        # display the missed day cross icon
 #                   twoweeks_bar_thisweek = twoweeks_bar_thisweek_missed                        # display the missed day cross icon
 #               elif display_repaired_lastweek == True:
 #                   twoweeks_bar_lastweek = twoweeks_bar_lastweek_repaired                      # display the band aid icon
 #                   twoweeks_bar_thisweek = twoweeks_bar_thisweek_repaired                      # display the band aid icon
 #               else:
                    twoweeks_bar_lastweek = twoweeks_bar_lastweek_normal    # display the normal progress indicator
                    twoweeks_bar_thisweek = twoweeks_bar_thisweek_normal

            twoweeks_bar = [

                # Last week narrow bar
                twoweeks_bar_lastweek,

                # This week wide bar
                twoweeks_bar_thisweek,
                
                # Spacer bar
                render.Box( # spacer column
                    width=1, 
                    height=(vertbar_total_height), 
                    color="#000000",
                ),
            ]


            # Choose which display to show
            if display_view == "week":
                show_chartbar = oneweek_bar
            elif display_view == "twoweeks":
                show_chartbar = twoweeks_bar

            vertbar = render.Row(
                main_align = "space_evenly",
                cross_align = "center", # Controls vertical alignment
                expanded = False,
                children = show_chartbar,
            )

            # Setup which streak icon to display
            streak_icon_day_frozen = bool(duolingo_xpsummary_json["summaries"][daynum]["frozen"])
            streak_icon_day_extended = bool(duolingo_xpsummary_json["summaries"][daynum]["streakExtended"])

#            if streak_icon_day_extended == True:
#                streak_icon = STREAK_ICON_GOLD
#            elif streak_icon_day_frozen == True:
#                streak_icon = STREAK_ICON_FROZEN
#            else:
#                streak_icon = STREAK_ICON_GREY


            # Calculate cache countdown
 #           cache_countdown = xp_query_time - now
 #           print("Cache Countdown: " + cache_countdown)



            # Get day of week, based on when the xp summary data was last updated:
            if daynum == 0: # TODAY
                dayofweek = xp_query_time
            elif daynum == 1: # YESTERDAY
                dayofweek = xp_query_time - time.parse_duration("24h")
            elif daynum == 2: # TWO DAYS AGO
                dayofweek = xp_query_time - time.parse_duration("48h")
            elif daynum == 3: # THREE DAYS AGO
                dayofweek = xp_query_time - time.parse_duration("72h")
            elif daynum == 4: # FOUR DAYS AGO
                dayofweek = xp_query_time - time.parse_duration("96h")
            elif daynum == 5: # FIVE DAYS AGO
                dayofweek = xp_query_time - time.parse_duration("120h")
            elif daynum == 6: # SIX DAYS AGO
                dayofweek = xp_query_time - time.parse_duration("144h")


            # Convert day of week to single lower case letter
            dayofweek_letter = dayofweek.format("Mon").lower()[0]

            if display_view == "week":
                print( "Day of Week: " + str(dayofweek_letter) + "  XP Score: " + str(xp_day_score))
            elif display_view == "twoweeks":
                print( "Day of Week: " + str(dayofweek_letter) + "  Last Week XP Score: " + str(xp_day_score_lastweek)+ "   This Week XP Score: " + str(xp_day_score))


            # Get current day of week
 #           if dayofweek = "m":
 #               dayofweek_letter = now.format("M").upper()
 #               dayofweek_font = now.format("M").upper()
 #               dayofweek_text_color = now.format("M").upper()



            day_progress_chart = render.Column(
                main_align = "end",
                cross_align = "center", # Controls vertical alignment
                expanded = True,
                children = [
                    vertbar,
                    render.Row(
                        main_align = "space_evenly",
                        cross_align = "end", # Controls vertical alignment
                        expanded = False,
                        children = [
                            render.Box(
                                width=1, 
                                height=7, 
                            ),
                            render.Text(str(dayofweek_letter), font = "tom-thumb"),
                            render.Box(
                                width=1, 
                                height=7, 
                            ),
                        ],
                    ),
                    

                ]
            )

            week_progress_chart.append(day_progress_chart)



        display_output = render.Box(



            render.Row(
                expanded = True,
                main_align = "space_evenly",
                cross_align = "center",
                children = [

                    # Display Duolingo icon and username
                    render.Column(
                        main_align = "center",
                        cross_align = "center", # Controls vertical alignment
                        expanded = True,
                        children = [

                            render.Row(
                                main_align = "space_evenly",
                                cross_align = "space_evenly", # Controls vertical alignment
                                expanded = False,
                                children = [
                                    render.Image(src = DUOLINGO_ICON),
                                ],
                            ),
                            render.Box(
                                width=22, 
                                height=1, 
                                color="#000000",
                            ),                            
                            nickname_today_view
                        ],
                    ),

                    # Display Progress Chart
                    render.Column(
                        main_align = "space_evenly",
                        cross_align = "center", # Controls vertical alignment
                        expanded = True,
                        children = [

                            # Display week progress chart
                            render.Row(
                                main_align = "end",
                                cross_align = "end",
                                expanded = True,
                                children = week_progress_chart,
                            ),                                                    
                        ],
                    ),

                ],
            ),
        )




    return render.Root(
        child = display_output,
    )



