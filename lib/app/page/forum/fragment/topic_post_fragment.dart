import 'package:flutter/material.dart';
import 'package:liver3rd/app/api/forum/post_api.dart';
import 'package:liver3rd/app/page/forum/widget/post_block.dart';
import 'package:liver3rd/app/store/user.dart';
import 'package:liver3rd/app/widget/common_widget.dart';
import 'package:liver3rd/app/widget/user_profile_label.dart';
import 'package:liver3rd/custom/easy_refresh/bezier_bounce_footer.dart';
import 'package:liver3rd/custom/easy_refresh/bezier_circle_header.dart';
import 'package:liver3rd/custom/easy_refresh/easy_refresh.dart';
import 'package:liver3rd/custom/navigate/navigate.dart';
import 'package:provider/provider.dart';

class TopicPostFragment extends StatefulWidget {
  final double usedHeight;
  final bool isGood;
  final bool isHot;
  final int sortType;
  final int forumId;

  const TopicPostFragment(
      {Key key,
      this.usedHeight,
      this.isGood = false,
      this.isHot = false,
      this.sortType = 1,
      this.forumId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TopicPostFragmentState();
  }
}

class _TopicPostFragmentState extends State<TopicPostFragment>
    with AutomaticKeepAliveClientMixin {
  PostApi _postApi = PostApi();
  Map _tmpData = {};
  List _postList = [];
  int _tmpSortType = 1;

  bool _loadPostLocker = true;
  bool _postLastLocker = false;
  User _user;

  didChangeDependencies() async {
    super.didChangeDependencies();
    _user = Provider.of<User>(context);

    if (_postList.isEmpty) {
      await _refresh();
    }
  }

  Future<void> _refresh() async {
    _postList = [];
    Map tmp = await _postApi.fetchForumPostList(
        forumId: widget.forumId,
        isGood: widget.isGood,
        isHot: widget.isHot,
        sortType: widget.sortType,
        lastId: "");
    List posts = tmp['data']['list'];
    _tmpData = tmp;
    if (mounted) {
      setState(() {
        if (posts != null && posts.isNotEmpty) {
          _postList.addAll(posts);
        }
      });
    }
  }

  Future<void> _onLoadPost(BuildContext context) async {
    if (_postLastLocker) {
      Scaffold.of(context).showSnackBar(CommonWidget.snack('没有新的帖子'));
      return;
    }

    if (_loadPostLocker) {
      _loadPostLocker = false;
      _postApi
          .fetchForumPostList(
              forumId: widget.forumId,
              isGood: widget.isGood,
              isHot: widget.isHot,
              sortType: widget.sortType,
              lastId: _tmpData['data']['last_id'])
          .then((val) {
        _loadPostLocker = true;
        _tmpData = val;
        if (mounted) {
          setState(() {
            _postList.addAll(val['data']['list'] ?? []);
          });
        }
      });
    }

    if (_tmpData.isNotEmpty && _tmpData['data']['is_last']) {
      _postLastLocker = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _postList = [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenHeight = MediaQuery.of(context).size.height;

    if (_tmpSortType != widget.sortType) {
      _refresh();
      _tmpSortType = widget.sortType;
    }

    return EasyRefresh.custom(
      header: BezierCircleHeader(
          backgroundColor: Colors.white, color: Colors.blue[200]),
      footer: BezierBounceFooter(
          backgroundColor: Colors.white, color: Colors.blue[200]),
      onLoad: () async {
        _onLoadPost(context);
      },
      onRefresh: _refresh,
      slivers: _postList.isEmpty
          ? <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      height: screenHeight - widget.usedHeight,
                      child: CommonWidget.loading(),
                    );
                  },
                  childCount: 1,
                ),
              ),
            ]
          : <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Map post = _postList[index];
                    bool isUpvoted = post['self_operation']['attitude'] == 1;
                    return PostBlock(
                      imgList: post['image_list'],
                      onTapUpvote: (isCancel) async {
                        if (_user.isLogin) {
                          await _postApi.upvotePost(
                            postId: post['post']['post_id'],
                            isCancel: isCancel,
                          );
                        } else {
                          Navigate.navigate(context, 'login');
                        }
                      },
                      postContent: post['post']['content'],
                      title: post['post']['subject'],
                      stat: post['stat'],
                      topics: post['topics'],
                      isUpvoted: isUpvoted,
                      onImageTap: (i) {
                        Navigate.navigate(
                          context,
                          'photoviewpage',
                          arg: {
                            'images': post['image_list'],
                            'index': i,
                          },
                        );
                      },
                      onContentTap: () {
                        Navigate.navigate(context, 'post',
                            arg: {'postId': post['post']['post_id']});
                      },
                      headBlock: UserProfileLabel(
                        avatarUrl: post['user']['avatar_url'],
                        certificationType: post['user']['certification']
                            ['type'],
                        createAt: post['post']['created_at'],
                        level: post['user']['level_exp']['level'],
                        nickName: post['user']['nickname'],
                        onAvatarTap: (String heroTag) {
                          Navigate.navigate(
                            context,
                            'userprofile',
                            arg: {
                              'heroTag': heroTag,
                              'uid': post['user']['uid'],
                            },
                          );
                        },
                      ),
                    );
                  },
                  childCount: _postList.length,
                ),
              ),
            ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
