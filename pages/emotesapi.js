class EmotesApi {
    constructor(token) {
        this.token = token
        this.channel = '';
        this.channelId = '';
        this.clientId = '';
        // this.getChannelId();
        this.emotesList = {};
        this.orderedList = [];
        this.rankedList = [];
        this.authed = false;
        this.checkTwitchAuth();
    }

    loadEmotes(emoteSets) {
        this.getSevenChannel();
        this.getSevenGlobal();
        this.getBTTVChannel();
        this.getBTTVGlobal();
        this.getFFZChannel();
        this.getFFZGlobal();
        // this.getTwitchChannel();
        // this.getTwitchGlobal();
        this.getTwitchEmoteSets(emoteSets);
        // this.downloadEmotes();
        this.orderedEmotes();
    }

    checkTwitchAuth() {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://id.twitch.tv/oauth2/validate";
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var jsonResponse = JSON.parse(xmlhttp.responseText.toString());
                // console.log(jsonResponse["scopes"])
                parent.channel = jsonResponse["login"];
                parent.channelId = jsonResponse["user_id"].toString();
                parent.clientId = jsonResponse["client_id"];
                parent.authed = true;
            } else if (xmlhttp.readyState == 4 && xmlhttp.status != 200) {
                parent.authed = false;
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.setRequestHeader("Authorization", "OAuth " + this.token);
        xmlhttp.send();
    }

    orderedEmotes() {
        var res = [];
        Object.keys(this.emotesList).forEach((k) => {
            res.push(this.emotesList[k])
        });
        res.sort((a, b) => {
             var al = a.emoteName.toLowerCase();
             var bl = b.emoteName.toLowerCase();
             if (al < bl) {
                 return -1
             }
             if (al > bl) {
                return 1;
             }
             return 0;
         });
        this.orderedList = res;
        
        var res2 = [];

        Object.keys(this.emotesList).forEach((k) => {
            res2.push(this.emotesList[k])
        });
        res2.sort((a, b) => {
             var al = a.emoteName.length;
             var bl = b.emoteName.length;
             if (al < bl) {
                 return 1
             }
             if (al > bl) {
                return -1;
             }
             return 0;
         });
        this.rankedList = res2;
    }

    getChannelId() {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.ivr.fi/twitch/resolve/" + this.channel;
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var jsonResponse = JSON.parse(xmlhttp.responseText.toString());
                parent.channelId = jsonResponse['id'].toString();
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.send();
    }

    getSevenChannel() {
        if (this.channel === '') return;
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.7tv.app/v2/users/" + this.channel + "/emotes";
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var emotes = JSON.parse(xmlhttp.responseText.toString());
                emotes.forEach((e) => {
                    if (!(e['name'] in parent.emotesList)) {
                        parent.emotesList[e['name']] = {
                            'emoteId': e['id'],
                            'emoteName': e['name'],
                            'emoteCategory': '7TV Channel',
                            'emotePath': e['urls'][3][1]
                        };
                    }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.send();
    }

    getSevenGlobal() {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.7tv.app/v2/emotes/global";
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var emotes = JSON.parse(xmlhttp.responseText.toString());
                emotes.forEach((e) => {
                    if (!(e['name'] in parent.emotesList)) {
                        parent.emotesList[e['name']] = {
                            'emoteId': e['id'],
                            'emoteName': e['name'],
                            'emoteCategory': '7TV Global',
                            'emotePath': e['urls'][3][1]
                        };
                    }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.send();
    }

    getBTTVChannel() {
        if (this.channel === '') return;
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.betterttv.net/3/cached/users/twitch/" + this.channelId;
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var emotes = JSON.parse(xmlhttp.responseText.toString());
                emotes['channelEmotes'].forEach((e) => {
                    if (!(e['code'] in parent.emotesList)) {
                       parent.emotesList[e['code']] = {
                           'emoteId': e['id'],
                           'emoteName': e['code'],
                           'emoteCategory': 'BTTV Channel',
                           'emotePath': 'https://cdn.betterttv.net/emote/' + e['id'] + '/3x'
                       };
                    }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.send();
    }

    getBTTVGlobal() {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.betterttv.net/3/cached/emotes/global";
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var emotes = JSON.parse(xmlhttp.responseText.toString());
                emotes.forEach((e) => {
                   if (!(e['code'] in parent.emotesList)) {
                       parent.emotesList[e['code']] = {
                           'emoteId': e['id'],
                           'emoteName': e['code'],
                           'emoteCategory': 'BTTV Global',
                           'emotePath': 'https://cdn.betterttv.net/emote/' + e['id'] + '/3x'
                       };
                   }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.send();
    }

    getFFZChannel() {
        if (this.channel === '') return;
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.frankerfacez.com/v1/room/id/" + this.channelId;
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var emotes = JSON.parse(xmlhttp.responseText.toString());
                emotes['sets'][emotes['room']['set']]['emoticons'].forEach((e) => {
                   if (!(e['name'] in parent.emotesList)) {
                       parent.emotesList[e['name']] = {
                           'emoteId': e['id'],
                           'emoteName': e['name'],
                           'emoteCategory': 'FFZ Channel',
                           'emotePath': 'https:' + e['urls']['4']
                       };
                   }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.send();
    }

    getFFZGlobal() {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.frankerfacez.com/v1/set/global";
        var parent = this;
        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var emotes = JSON.parse(xmlhttp.responseText.toString());
                emotes['sets']['3']['emoticons'].forEach((e) => {
                   if (!(e['name'] in parent.emotesList)) {
                       parent.emotesList[e['name']] = {
                           'emoteId': e['id'],
                           'emoteName': e['name'],
                           'emoteCategory': 'FFZ Global',
                           'emotePath': 'https:' + e['urls']['4']
                       };
                   }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.send();
    }

    getTwitchChannel() {
        if (this.channel === '') return;
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.twitch.tv/helix/chat/emotes?broadcaster_id=" + this.channelId;
        var parent = this;
        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var jsonResponse = JSON.parse(xmlhttp.responseText.toString());
                var emotes = jsonResponse["data"];
                emotes.forEach((e) => {
                    if (!(e['name'] in parent.emotesList)) {
                        parent.emotesList[e['name']] = {
                            'emoteId': e['id'],
                            'emoteName': e['name'],
                            'emoteCategory': 'Twitch Channel',
                            'emotePath': 'https://static-cdn.jtvnw.net/emoticons/v2/' + e['id'] + '/default/dark/3.0'
                        };
                    }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.setRequestHeader("Authorization", "Bearer " + this.token);
        xmlhttp.setRequestHeader("Client-Id", this.clientId);
        xmlhttp.send();
    }

    getTwitchGlobal() {
        var xmlhttp = new XMLHttpRequest();
        var url = "https://api.twitch.tv/helix/chat/emotes/global";
        var parent = this;
        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                var jsonResponse = JSON.parse(xmlhttp.responseText.toString());
                var emotes = jsonResponse["data"];
                emotes.forEach((e) => {
                    if (!(e['name'] in parent.emotesList)) {
                        parent.emotesList[e['name']] = {
                            'emoteId': e['id'],
                            'emoteName': e['name'],
                            'emoteCategory': 'Twitch Global',
                            'emotePath': 'https://static-cdn.jtvnw.net/emoticons/v2/' + e['id'] + '/default/dark/3.0'
                        };
                    }
                });
            }
        }
        xmlhttp.open("GET", url, false);
        xmlhttp.setRequestHeader("Authorization", "Bearer " + this.token);
        xmlhttp.setRequestHeader("Client-Id", this.clientId);
        xmlhttp.send();
    }

    getTwitchEmoteSets(emoteSets) {
        for (var i = 0; i < emoteSets.length; i += 25) {
            var prepquery = emoteSets.slice(i,i+25).map((t) => {
                return "emote_set_id=" + t.toString();
            }).join("&");
            var xmlhttp = new XMLHttpRequest();
            var url = "https://api.twitch.tv/helix/chat/emotes/set?" + prepquery;
            var parent = this;
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                    var jsonResponse = JSON.parse(xmlhttp.responseText.toString());
                    var emotes = jsonResponse["data"];
                    emotes.forEach((e) => {
                        if (!(e['name'] in parent.emotesList)) {
                            parent.emotesList[e['name']] = {
                                'emoteId': e['id'],
                                'emoteName': e['name'],
                                'emoteCategory': 'Twitch' + e['emote_type'],
                                'emotePath': 'https://static-cdn.jtvnw.net/emoticons/v2/' + e['id'] + '/default/dark/3.0'
                            };
                        }
                    });
                }
            }
            xmlhttp.open("GET", url, false);
            xmlhttp.setRequestHeader("Authorization", "Bearer " + this.token);
            xmlhttp.setRequestHeader("Client-Id", this.clientId);
            xmlhttp.send();
        }
    }

    downloadEmotes() {
        for (let [k, v] of Object.entries(this.emotesList)) {
            var xmlhttp = new XMLHttpRequest();
            var url = v['emotePath'];
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                    // console.log(xmlhttp.response.toString());
                }
            }
            xmlhttp.open("GET", url, false);
            xmlhttp.send();
        }
    }
}
