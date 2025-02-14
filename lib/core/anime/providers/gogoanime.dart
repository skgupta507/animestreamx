import 'package:animestream/core/anime/extractors/streamwish.dart';
import 'package:animestream/core/anime/providers/types.dart';
import 'package:animestream/core/commons/types.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../extractors/vidstream.dart';

class GogoAnime extends AnimeProvider {
  final String _baseUrl = "https://anitaku.bz/";
  final String _ajaxUrl = "https://ajax.gogocdn.net/ajax";

  Future<List<Map<String, String?>>> search(String query) async {
    String searchUrl = "$_baseUrl/search.html?keyword=${Uri.encodeComponent(query)}";
    final res = await get(searchUrl);
    final document = html.parse(res.body);
    final titles = document.querySelectorAll(".items p.name");
    final imgs = document.querySelectorAll(".img");
    List<String> list = [];
    List<String> links = [];
    List<String> images = [];
    titles.forEach((element) {
      final pt = element.text.replaceAll(RegExp(r'\s+'), ' ');
      final link = element.children[0].attributes['href'];
      if (link != null) {
        list.add(pt);
        links.add(link);
      }
    });
    imgs.forEach((element) {
      final img = element.children[0].children[0].attributes['src'];
      if (img != null) {
        images.add(img);
      }
    });

    if (list.length == 0) {
      throw new Exception("NO_SEARCH_RESULTS");
    }

    List<Map<String, String?>> searchResults = [];

    for (int i = 0; i < list.length; i++) {
      final image = images[list.indexOf(list[i])];
      searchResults.add({
        'name': list[i].trim(),
        'alias': _baseUrl + links[list.indexOf(list[i])],
        'imageUrl': image.startsWith("https://") ? image : _baseUrl + image,
      });
    }

    return searchResults;
  }

  String _getServerLink(String serverName, List<Map<String, String>> servers) {
    final src = servers.where((element) => element['server']?.toLowerCase() == serverName.toLowerCase()).toList();
    if (src.isEmpty) {
      return '';
    }
    return src[0]['src'] ?? '';
  }

  Future<void> getStreams(String episodeId, Function(List<Stream>, bool) update) async {
    //get link of all listed servers from gogoanime
    final servers = await getAllServerLinks(episodeId);

    //pick the iframe link of given server
    final vsLink = _getServerLink("vidstreaming", servers);
    final swLink = _getServerLink("streamwish", servers);
    final alLink = _getServerLink("vidhide", servers);
    // final sources = [];
    int returns = 0;
    int totalStreams = 3; //update this when new source is added for gogo
    final vidstream = Vidstream().extract(vsLink);
    final streamwish = StreamWish().extract(swLink);
    final alions = StreamWish().extract(alLink);

    //updates the array when a new source is found
    vidstream.then((res) {
      returns++;
      update(res, returns == totalStreams);
    }).catchError((error) {
      print(error);
      returns++;
      update([], returns == totalStreams);
    });

    streamwish.then((res) {
      returns++;
      update(res, returns == totalStreams);
    }).catchError((error) {
      print(error);
      returns++;
      update([], returns == totalStreams);
    });

    alions.then((res) {
      returns++;
      update(res, returns == totalStreams);
    }).catchError((error) {
      print(error);
      returns++;
      update([], returns == totalStreams);
    });
    // sources.addAll([vidstream, streamwish]);
    // return sources.expand((element) => element).toList();
  }

  Future<List<String>> getAnimeEpisodeLink(String aliasId) async {
    dynamic url = aliasId;
    if (!url.startsWith("http")) url = '$_baseUrl/category/$aliasId';
    final res = await get(url);
    final document = html.parse(res.body);

    final epStart = document.querySelector('.anime_video_body > ul > li > a')?.attributes['ep_start'];
    final epEnd = document.querySelector('.anime_video_body > ul > li:last-child > a')?.attributes['ep_end'];
    if (epEnd == null) {
      throw Exception('Couldn\'t find end Eps');
    }
    final alias = document.querySelector('#alias_anime')?.attributes['value'];
    final movieId = document.querySelector('#movie_id')?.attributes['value'];

    final ajaxurl = '$_ajaxUrl/load-list-episode?ep_start=$epStart&ep_end=$epEnd&id=$movieId&default_ep=0&alias=$alias';
    final ajaxres = await get(ajaxurl);
    final parsedAjaxRes = html.parse(ajaxres.body);

    final link = parsedAjaxRes.querySelector('a')?.attributes['href'];
    if (link == null) {
      throw Exception('No links found');
    }

    final split = link.split('-');
    final totalEps = int.parse(epEnd);
    final baseEpLink = _baseUrl + '${split.sublist(0, split.length - 1).join('-')}-'.trim();
    final List<String> episodes = [];
    for (int i = 1; i <= totalEps; i++) {
      episodes.add("${baseEpLink}$i");
    }
    return episodes;
    // return {'link': _baseUrl + '${split.sublist(0, split.length - 1).join('-')}-'.trim(), 'episodes': };
  }

  Future<List<Map<String, String>>> getAllServerLinks(String epUrl) async {
    final res = await get(epUrl);
    final $ = html.parse(res.body);
    List<Map<String, String>> serverArray = [];
    $.querySelectorAll('div.anime_muti_link > ul > li').forEach((e) {
      final serverName = e.attributes['class'] ?? '';
      final srcChildren = e.children;
      var src;
      for (var child in srcChildren) {
        final dataVideo = child.attributes['data-video'];
        if (dataVideo != null) {
          src = dataVideo;
        }
      }
      serverArray.add({
        'server': serverName == 'anime' ? 'vidstreaming' : serverName,
        'src': src,
      });
    });
    return serverArray;
  }

  Future<http.Response> get(String url) async {
    final response = await http.get(Uri.parse(url));
    return response;
  }

  @override
  Future<void> getDownloadSources(String episodeUrl, Function(List<Stream> p1, bool p2) update) {
    throw UnimplementedError();
  }
}
