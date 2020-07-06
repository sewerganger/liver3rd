import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liver3rd/app/api/shop/shop_api.dart';
import 'package:liver3rd/app/widget/common_widget.dart';
import 'package:liver3rd/app/widget/present_card.dart';
import 'package:liver3rd/custom/easy_refresh/bezier_bounce_footer.dart';
import 'package:liver3rd/custom/easy_refresh/bezier_circle_header.dart';
import 'package:liver3rd/custom/easy_refresh/src/refresher.dart';

import 'package:liver3rd/custom/navigate/navigate.dart';

class ShopPresentPage extends StatefulWidget {
  final ScrollController nestController;

  const ShopPresentPage({Key key, this.nestController}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShopPresentPageState();
  }
}

class _ShopPresentPageState extends State<ShopPresentPage> {
  final String heroTag = 'goods_tag';
  ShopApi _shopApi = ShopApi();
  ScrollController _scrollController;
  List _goods = [];
  Map _presents = {};
  int _currentPage = 1;

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        widget.nestController.jumpTo(_scrollController.offset);
      });
  }

  Future<void> _fetchGoods(int page) async {
    _presents = await _shopApi.fetchPresents(page: page);
    if (mounted) {
      setState(() {
        _goods.addAll(_presents['data']['list']);
      });
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_presents.isEmpty) {
      await _fetchGoods(_currentPage);
    }
  }

  @override
  dispose() {
    super.dispose();
    _scrollController?.dispose();
    _goods = [];
  }

  Future<void> _loadGoods() async {
    int total = _presents['data']['total'];

    if (total - _goods.length > 0) {
      await _fetchGoods(_currentPage + 1);
    }
  }

  Future<void> _refreshGoods() async {
    _goods = [];
    _currentPage = 1;
    await _fetchGoods(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _goods.length <= 0
          ? CommonWidget.loading()
          : EasyRefresh.custom(
              scrollController: _scrollController,
              header: BezierCircleHeader(
                backgroundColor: Colors.white,
                color: Colors.blue[200],
              ),
              footer: BezierBounceFooter(
                backgroundColor: Colors.white,
                color: Colors.blue[200],
              ),
              onRefresh: _refreshGoods,
              onLoad: _loadGoods,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return SizedBox(height: ScreenUtil().setHeight(40));
                  }, childCount: 1),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    Map g = _goods[index];
                    String heroTag = 'presents$index';
                    return PresentCard(
                      heroTag: heroTag,
                      goodsName: g['goods_name'],
                      accountCycleLimit: g['account_cycle_limit'],
                      accountExchangeNum: g['account_exchange_num'],
                      total: g['total'],
                      unlimit: g['unlimit'],
                      price: g['price'],
                      type: g['type'],
                      coverImgUrl: g['icon'],
                      onPressed: () {
                        Navigate.navigate(context, 'presentdetail', arg: {
                          'heroTag': heroTag,
                          'goodsName': g['goods_name'],
                          'accountCycleLimit': g['account_cycle_limit'],
                          'accountExchangeNum': g['account_exchange_num'],
                          'total': g['total'],
                          'unlimit': g['unlimit'],
                          'price': g['price'],
                          'type': g['type'],
                          'coverImgUrl': g['icon'],
                          'appId': g['app_id'],
                          'goodsId': g['goods_id'],
                          'pointSn': g['point_sn']
                        });
                      },
                    );
                  }, childCount: _goods.length),
                ),
              ],
            ),
    );
  }
}
