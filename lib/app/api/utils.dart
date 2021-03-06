import 'package:dio/dio.dart';
import 'package:device_info/device_info.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:liver3rd/app/utils/share.dart';
import 'package:liver3rd/app/utils/const_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:liver3rd/app/utils/tiny_utils.dart';

String webviewUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Redmi Note 4X Build/MRA58K; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.132 Mobile Safari/537.36 miHoYoBBS/2.2.0';

class ReqUtils {
  DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  Dio _dio;
  ReqUtils({String baseUrl}) {
    _dio = baseUrl != null ? Dio(BaseOptions(baseUrl: baseUrl)) : Dio();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          if (TinyUtils.isDev) {
            print(options.uri.toString());
          }

          String uid = await Share.getString(UID);
          String stoken = await Share.getString(STOKEN);
          String ltoken = await Share.getString(LTOKEN);
          if (uid != null && stoken != null) {
            options.headers['cookie'] =
                'stuid=$uid;uid=$uid;stoken=$stoken;account_id=$uid;ltoken=$ltoken;ltuid=$uid';
          }
          return options;
        },
        // onResponse: (Response response) async {
        //   if (response.data == null || response.data['retcode'] != 0) {
        //     Fluttertoast.showToast(
        //       msg: '请求出错: ' + response.data['message'],
        //       toastLength: Toast.LENGTH_LONG,
        //       gravity: ToastGravity.CENTER,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.red[300],
        //       textColor: Colors.white,
        //       fontSize: 16.0,
        //     );l
        //   }
        //   return response;
        // },
      ),
    );
  }

  Future<Response> get(
    String url, {
    Options options,
    Map queryParameters = const {},
  }) async {
    return _dio.get(
      url,
      options: options,
      queryParameters: Map.from(queryParameters),
    );
  }

  Future<Response> post(
    String url, {
    Options options,
    Map<String, dynamic> queryParameters = const {},
    dynamic data,
  }) async {
    return _dio.post(
      url,
      options: options,
      queryParameters: Map.from(queryParameters),
      data: data,
    );
  }

  static Map<String, dynamic> siteHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.106 Safari/537.36',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': 1
  };

  Map<String, String> customHeaders(
      {host, referer, origin, cookie, Map others}) {
    Map<String, String> headers = {
      'GlobalModel-Agent': 'okhttp/3.14.7',
      'Accept-Encoding': 'gzip',
      'Connection': 'keep-alive',
      'Accept': '*/*'
    };

    if (others != null) {
      headers.addAll(others);
    }

    if (host != null) {
      headers.addAll({'Host': host});
    }

    if (referer != null) {
      headers.addAll({'Referer': referer});
    }

    if (origin != null) {
      headers.addAll({'Origin': origin});
    }

    if (cookie != null) {
      headers.addAll({'Cookie': cookie});
    }
    return headers;
  }

  Future<Map<String, String>> setDeviceHeader(
      {host, referer, origin, cookie}) async {
    AndroidDeviceInfo info = await _deviceInfo.androidInfo;
    Map<String, String> deviceHeaders = {
      'x-rpc-client_type': '2',
      'x-rpc-app_version': '2.2.0',
      'x-rpc-sys_version': '${info.version.release}',
      'x-rpc-channel': '${info.brand}',
      'x-rpc-device_id': '${info.androidId}',
      'x-rpc-device_name': '${info.brand} ${info.model}',
      'x-rpc-device_model': '${info.model}',
      'user-agent': webviewUserAgent,
    };
    deviceHeaders.addAll(
      customHeaders(
        host: host,
        referer: referer,
        origin: origin,
        cookie: cookie,
      ),
    );
    return deviceHeaders;
  }

  Future<void> download(String url, String name,
      {Function onSuccess, Function onError}) async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + '/$name';
    await Dio().download(url, savePath);
    final result = await ImageGallerySaver.saveFile(savePath);
    if (result != null) {
      onSuccess != null && onSuccess();
    } else {
      onError != null && onError();
    }
  }
}
