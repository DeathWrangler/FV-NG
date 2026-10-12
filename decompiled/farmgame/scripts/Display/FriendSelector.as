package Display
{
   import Classes.EmbeddedArt;
   import Classes.Friend;
   import Classes.IUser;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.CloseEvent;
   import Transactions.TUpdateW2WSentHistory;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class FriendSelector extends SlotDialog
   {
      
      protected const DEFAULT_NUM_SLOTS:int = 6;
      
      protected const DEFAULT_DIALOG_ASSET:String = "assets/dialogs/FV_FriendChooser2.swf";
      
      protected var m_selectedFriends:Array = new Array();
      
      protected var m_multiSelect:Boolean;
      
      protected var m_checkMinMax:Boolean;
      
      protected var m_LocalizationBundle:String = "Dialogs";
      
      protected var m_friendSelectorCongratulations:String = "FriendSelectorCongratulations";
      
      protected var m_friendSelectorCongratulationsParams:Object = null;
      
      protected var m_friendSelectorTitle:String = "FriendSelectorTitle";
      
      protected var m_friendSelectorTitleParams:Object = null;
      
      protected var m_friendSelectorNextDetail:String = "";
      
      protected var m_minFriends:int = 0;
      
      protected var m_maxFriends:int = 0;
      
      protected var m_filterEmailPermission:Boolean;
      
      protected var m_errorPopup:GenericPopup;
      
      protected var m_allFarmvilleFriends:Boolean = false;
      
      protected var m_onSendCallback:Function = null;
      
      protected var m_farmItem:FarmItem = null;
      
      protected var m_farmIcon:FarmIcon = null;
      
      private var m_hasSentHash:Object = {};
      
      private var m_limitOneSend:Boolean = false;
      
      private var m_friendArray:Array = null;
      
      private var m_featureName:String = null;
      
      private var m_feedName:String = null;
      
      public function FriendSelector(multiSelect:Boolean = false, minFriends:int = 0, maxFriends:int = 0, filterEmailPermission:Boolean = false, onSendCallback:Function = null, farmItem:FarmItem = null, friendArray:Array = null, limitOneSend:Boolean = false, dialogAsset:String = "assets/dialogs/FV_FriendChooser2.swf", featureName:String = null, feedName:String = null)
      {
         this.m_multiSelect = multiSelect;
         this.m_checkMinMax = minFriends > 0 && maxFriends > 0;
         this.m_minFriends = minFriends;
         this.m_maxFriends = maxFriends;
         this.m_filterEmailPermission = filterEmailPermission;
         this.m_onSendCallback = onSendCallback;
         this.m_farmItem = farmItem;
         this.m_friendArray = friendArray != null ? friendArray : Global.friendManager.neighbors;
         this.m_limitOneSend = limitOneSend;
         m_dialogAsset = dialogAsset;
         this.m_featureName = featureName;
         this.m_feedName = feedName;
         super();
      }
      
      public function set localizationBundle(localizationBundle:String) : void
      {
         this.m_LocalizationBundle = localizationBundle;
      }
      
      public function setCongratulations(congratulationsId:String, params:Object = null) : void
      {
         this.m_friendSelectorCongratulations = congratulationsId;
         this.m_friendSelectorCongratulationsParams = params;
         if(m_window)
         {
            if(this.m_friendSelectorCongratulations == "")
            {
               m_window.friendChooser_mc.congratulations_tf.text = this.m_friendSelectorCongratulations;
            }
            else
            {
               m_window.friendChooser_mc.congratulations_tf.text = ZLocUtils.t("Dialogs",this.m_friendSelectorCongratulations,this.m_friendSelectorCongratulationsParams);
            }
         }
      }
      
      public function setTitle(titleId:String, params:Object = null) : void
      {
         this.m_friendSelectorTitle = titleId;
         this.m_friendSelectorTitleParams = params;
         if(m_window)
         {
            if(this.m_friendSelectorTitle == "")
            {
               m_window.friendChooser_mc.title_tf.text = this.m_friendSelectorTitle;
            }
            else
            {
               m_window.friendChooser_mc.title_tf.text = ZLocUtils.t("Dialogs",this.m_friendSelectorTitle,this.m_friendSelectorTitleParams);
            }
         }
      }
      
      public function setNextDetailText(nextDetailId:String) : void
      {
         this.m_friendSelectorNextDetail = nextDetailId;
         if(m_window)
         {
            m_window.friendChooser_mc.customize_tf.visible = true;
            m_window.friendChooser_mc.customize_tf.text = ZLocUtils.t("Dialogs",this.m_friendSelectorNextDetail);
         }
      }
      
      public function getSelectedFriends() : Array
      {
         return this.m_selectedFriends;
      }
      
      public function getSelectedFriendsUID() : Array
      {
         var player:IUser = null;
         var friendsUID:Array = new Array();
         for each(player in this.m_selectedFriends)
         {
            friendsUID.push(player.uid.toString());
         }
         return friendsUID;
      }
      
      override protected function onLoadComplete() : void
      {
         var next_bt:GenericButton = null;
         super.onLoadComplete();
         m_window.friendChooser_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         this.enableArrowButtons();
         m_window.friendChooser_mc.congratulations_tf.text = ZLocUtils.t(this.m_LocalizationBundle,this.m_friendSelectorCongratulations,this.m_friendSelectorCongratulationsParams);
         m_window.friendChooser_mc.title_tf.text = ZLocUtils.t(this.m_LocalizationBundle,this.m_friendSelectorTitle,this.m_friendSelectorTitleParams);
         if(this.m_farmItem != null)
         {
            this.m_farmIcon = new FarmIcon(m_window.friendChooser_mc.prize_mc.icon_mc,this.m_farmItem.icon);
            m_window.friendChooser_mc.customize_tf.visible = false;
            m_window.friendChooser_mc.next_bt.visible = false;
         }
         else
         {
            m_window.friendChooser_mc.prize_mc.visible = false;
            if(this.m_friendSelectorNextDetail != "")
            {
               m_window.friendChooser_mc.customize_tf.text = ZLocUtils.t("Dialogs",this.m_friendSelectorNextDetail);
            }
            else
            {
               m_window.friendChooser_mc.customize_tf.visible = false;
            }
            next_bt = new GenericButton(m_window.friendChooser_mc.next_bt,this.onNextClick);
            next_bt.m_overlay.name = "next_bt";
            next_bt.enableHitState(true);
            next_bt.text = ZLocUtils.t("Dialogs","NextCap");
         }
         if(m_dialogAsset == "assets/dialogs/FV_FriendChooser2.swf")
         {
            m_tiles.push(m_window.friendChooser_mc.friendCard1_mc,m_window.friendChooser_mc.friendCard2_mc,m_window.friendChooser_mc.friendCard3_mc,m_window.friendChooser_mc.friendCard4_mc,m_window.friendChooser_mc.friendCard5_mc,m_window.friendChooser_mc.friendCard6_mc,m_window.friendChooser_mc.friendCard7_mc,m_window.friendChooser_mc.friendCard8_mc,m_window.friendChooser_mc.friendCard9_mc,m_window.friendChooser_mc.friendCard10_mc,m_window.friendChooser_mc.friendCard11_mc,m_window.friendChooser_mc.friendCard12_mc);
         }
         else if(m_dialogAsset == "assets/dialogs/FV_FriendChooser9.swf")
         {
            m_tiles.push(m_window.friendChooser_mc.friendCard1_mc,m_window.friendChooser_mc.friendCard2_mc,m_window.friendChooser_mc.friendCard3_mc,m_window.friendChooser_mc.friendCard4_mc,m_window.friendChooser_mc.friendCard5_mc,m_window.friendChooser_mc.friendCard6_mc,m_window.friendChooser_mc.friendCard7_mc,m_window.friendChooser_mc.friendCard8_mc,m_window.friendChooser_mc.friendCard9_mc);
         }
         else if(m_dialogAsset == "assets/dialogs/FV_FriendChooser6.swf")
         {
            m_tiles.push(m_window.friendChooser_mc.friendCard1_mc,m_window.friendChooser_mc.friendCard2_mc,m_window.friendChooser_mc.friendCard3_mc,m_window.friendChooser_mc.friendCard4_mc,m_window.friendChooser_mc.friendCard5_mc,m_window.friendChooser_mc.friendCard6_mc);
         }
         else
         {
            m_tiles.push(m_window.friendChooser_mc.friendCard1_mc,m_window.friendChooser_mc.friendCard2_mc,m_window.friendChooser_mc.friendCard3_mc);
         }
         removeTiles();
         this.pushNewData();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
      }
      
      override protected function getNumSlots() : int
      {
         var numSlots:int = this.DEFAULT_NUM_SLOTS;
         switch(m_dialogAsset)
         {
            case "assets/dialogs/FV_FriendChooser2.swf":
               numSlots = 12;
               break;
            case "assets/dialogs/FV_FriendChooser9.swf":
               numSlots = 9;
               break;
            case "assets/dialogs/FV_FriendChooser6.swf":
               numSlots = 6;
               break;
            default:
               numSlots = 3;
         }
         return numSlots;
      }
      
      override protected function fixArrows() : void
      {
         m_window.friendChooser_mc.arrowLt_bt.visible = m_tileSet > 0 ? true : false;
         m_window.friendChooser_mc.arrowRt_bt.visible = (m_tileSet + 1) * this.getNumSlots() < m_data.length ? true : false;
      }
      
      protected function pushNewData() : void
      {
         var friends:Array = null;
         var tempfriends:Array = null;
         var unsortedFriend:Friend = null;
         var friendBarSlot:Friend = null;
         m_data = [];
         m_tileSet = 0;
         if(this.m_friendArray != null)
         {
            friends = this.m_friendArray;
         }
         else if(this.m_allFarmvilleFriends)
         {
            friends = Global.friendManager.appFriends;
         }
         else
         {
            friends = Global.friendManager.neighbors;
         }
         if(friends)
         {
            tempfriends = new Array();
            for each(friendBarSlot in friends)
            {
               if(false == this.m_filterEmailPermission || friendBarSlot.hasEmailPermission)
               {
                  tempfriends.push(friendBarSlot);
               }
            }
            tempfriends.sortOn("name");
            m_data = tempfriends.slice();
         }
         this.fixArrows();
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var url:String = null;
         var sendButton:MovieClip = null;
         var icon:Loader = null;
         var dispObj:DisplayObject = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            tile = m_tiles[compId] as MovieClip;
            tile.visible = true;
            tile.gotoAndStop(1);
            if(this.m_onSendCallback == null)
            {
               tile.addEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseOver);
               tile.addEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseOut);
               tile.addEventListener(MouseEvent.CLICK,this.onTileMouseClick);
               tile.send_bt.visible = false;
               tile.checked = false;
               if(this.isFriendSelected(m_data[index + compId] as IUser))
               {
                  tile.checked = true;
               }
               if(tile.checked)
               {
                  tile.gotoAndStop(3);
               }
               else
               {
                  tile.gotoAndStop(1);
               }
            }
            else
            {
               sendButton = tile.send_bt;
               tile.send_bt.generic_tf.text = ZLocUtils.t("Dialogs","Share").toUpperCase();
               tile.send_bt.visible = true;
               tile.send_bt.snUser = m_data[index + compId].snUser;
               sendButton.uid = m_data[index + compId].uid;
               if(Boolean(this.m_hasSentHash[sendButton.uid]) || this.m_limitOneSend && Global.player.w2wState.getRecentlySent(this.m_featureName,this.m_feedName,sendButton.uid))
               {
                  this.disableSendButton(sendButton);
               }
               else
               {
                  this.enableSendButton(sendButton);
               }
            }
            tile.id = index + compId;
            tile.itemTitle_tf.text = m_data[index + compId].name;
            url = m_data[index + compId].snUser.picture;
            if(url)
            {
               icon = LoadingManager.load(url,function(event:Event):void
               {
                  var dispObj:* = undefined;
                  if(Boolean(icon) && Boolean(icon.content))
                  {
                     if(tile)
                     {
                        Utilities.removeAllChildren(tile.icon);
                     }
                     dispObj = icon.content;
                     dispObj.width = 50;
                     dispObj.height = 50;
                     tile.icon.addChild(dispObj);
                  }
               });
            }
            else
            {
               if(tile)
               {
                  Utilities.removeAllChildren(tile.icon);
               }
               dispObj = new EmbeddedArt.hud_no_profile_pic();
               dispObj.width = 50;
               dispObj.height = 50;
               tile.icon.addChild(dispObj);
            }
         }
      }
      
      protected function removeComponent(compId:int) : void
      {
         var tile:MovieClip = null;
         var sendButton:MovieClip = null;
         if(Boolean(m_tiles) && m_data[compId] != null)
         {
            tile = m_tiles[compId] as MovieClip;
            tile.visible = true;
            tile.removeEventListener(MouseEvent.MOUSE_OVER,this.onTileMouseOver);
            tile.removeEventListener(MouseEvent.MOUSE_OUT,this.onTileMouseOut);
            tile.removeEventListener(MouseEvent.CLICK,this.onTileMouseClick);
            sendButton = tile.send_bt;
            sendButton.removeEventListener(MouseEvent.MOUSE_OVER,this.onSendMouseOver);
            sendButton.removeEventListener(MouseEvent.MOUSE_OUT,this.onSendMouseOut);
            sendButton.removeEventListener(MouseEvent.CLICK,this.onSendMouseClick);
         }
      }
      
      protected function onSendMouseOver(event:MouseEvent) : void
      {
         var sendButton:MovieClip = null;
         if(event.target is MovieClip)
         {
            sendButton = event.target as MovieClip;
         }
         else if(event.target is TextField)
         {
            sendButton = (event.target as TextField).parent as MovieClip;
         }
         if(sendButton)
         {
            sendButton.gotoAndStop(2);
         }
      }
      
      protected function onSendMouseOut(event:MouseEvent) : void
      {
         var sendButton:MovieClip = null;
         if(event.target is MovieClip)
         {
            sendButton = event.target as MovieClip;
         }
         else if(event.target is TextField)
         {
            sendButton = (event.target as TextField).parent as MovieClip;
         }
         if(sendButton)
         {
            sendButton.gotoAndStop(1);
         }
      }
      
      protected function onSendMouseClick(event:MouseEvent) : void
      {
         var t:TUpdateW2WSentHistory = null;
         var sendButton:MovieClip = null;
         if(event.target is MovieClip)
         {
            sendButton = event.target as MovieClip;
         }
         else if(event.target is TextField)
         {
            sendButton = (event.target as TextField).parent as MovieClip;
         }
         if(sendButton)
         {
            if(this.m_limitOneSend)
            {
               Global.player.w2wState.setRecentlySent(this.m_featureName,this.m_feedName,sendButton.uid,GlobalEngine.serverTime);
               t = new TUpdateW2WSentHistory(this.m_featureName,this.m_feedName,sendButton.uid);
               TransactionManager.addTransaction(t,true);
            }
            this.m_onSendCallback(sendButton);
         }
      }
      
      public function setHasSent(sendButton:MovieClip) : void
      {
         this.m_hasSentHash[sendButton.uid] = true;
      }
      
      public function enableSendButton(sendButton:MovieClip) : void
      {
         sendButton.addEventListener(MouseEvent.MOUSE_OVER,this.onSendMouseOver);
         sendButton.addEventListener(MouseEvent.MOUSE_OUT,this.onSendMouseOut);
         sendButton.addEventListener(MouseEvent.CLICK,this.onSendMouseClick);
         sendButton.gotoAndStop(1);
      }
      
      public function enableSendButtons() : void
      {
         var tile:MovieClip = null;
         var sendButton:MovieClip = null;
         var index:int = m_tileSet * this.getNumSlots();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            tile = m_tiles[compIdx] as MovieClip;
            sendButton = tile.send_bt;
            if(!this.m_hasSentHash[sendButton.uid])
            {
               this.enableSendButton(sendButton);
            }
            else
            {
               this.disableSendButton(sendButton);
            }
            compIdx++;
         }
         this.enableArrowButtons();
      }
      
      public function enableArrowButtons() : void
      {
         m_window.friendChooser_mc.arrowLt_bt.enabled = true;
         m_window.friendChooser_mc.arrowRt_bt.enabled = true;
         m_window.friendChooser_mc.arrowLt_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.friendChooser_mc.arrowRt_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
      }
      
      public function disableSendButton(sendButton:MovieClip) : void
      {
         sendButton.removeEventListener(MouseEvent.MOUSE_OVER,this.onSendMouseOver);
         sendButton.removeEventListener(MouseEvent.MOUSE_OUT,this.onSendMouseOut);
         sendButton.removeEventListener(MouseEvent.CLICK,this.onSendMouseClick);
         sendButton.gotoAndStop(4);
      }
      
      public function disableSendButtons() : void
      {
         var tile:MovieClip = null;
         var sendButton:MovieClip = null;
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            tile = m_tiles[compIdx] as MovieClip;
            sendButton = tile.send_bt;
            this.disableSendButton(sendButton);
            compIdx++;
         }
         this.disableArrowButtons();
      }
      
      public function disableArrowButtons() : void
      {
         m_window.friendChooser_mc.arrowLt_bt.enabled = false;
         m_window.friendChooser_mc.arrowRt_bt.enabled = false;
         m_window.friendChooser_mc.arrowLt_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.friendChooser_mc.arrowRt_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
      }
      
      protected function onTileMouseOver(event:MouseEvent) : void
      {
         var tile:MovieClip = null;
         if(event.target.hasOwnProperty("checked"))
         {
            tile = event.target as MovieClip;
         }
         else
         {
            tile = event.target.parent as MovieClip;
         }
         if(tile.checked)
         {
            tile.gotoAndStop(4);
         }
         else
         {
            tile.gotoAndStop(2);
         }
      }
      
      protected function onTileMouseOut(event:MouseEvent) : void
      {
         var tile:MovieClip = null;
         if(event.target.hasOwnProperty("checked"))
         {
            tile = event.target as MovieClip;
         }
         else
         {
            tile = event.target.parent as MovieClip;
         }
         if(tile.checked)
         {
            tile.gotoAndStop(3);
         }
         else
         {
            tile.gotoAndStop(1);
         }
      }
      
      protected function onTileMouseClick(event:MouseEvent) : void
      {
         var tile:MovieClip = null;
         if(event.target.hasOwnProperty("checked"))
         {
            tile = event.target as MovieClip;
         }
         else
         {
            tile = event.target.parent as MovieClip;
         }
         tile.checked = !tile.checked;
         if(tile.checked)
         {
            this.handleAddFriend(tile.id);
            tile.gotoAndStop(4);
         }
         else
         {
            this.handleRemoveFriend(tile.id);
            tile.gotoAndStop(2);
         }
      }
      
      protected function isFriendSelected(friend:IUser) : Boolean
      {
         var friendIdx:int = 0;
         var result:Boolean = false;
         if(friend)
         {
            for(friendIdx = 0; friendIdx < this.m_selectedFriends.length; friendIdx++)
            {
               if(Boolean(this.m_selectedFriends[friendIdx]) && this.m_selectedFriends[friendIdx].uid == friend.uid)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      protected function handleAddFriend(index:int) : void
      {
         var uncheckIndex:int = 0;
         var tile:MovieClip = null;
         if(!this.m_multiSelect && this.m_selectedFriends.length > 0)
         {
            uncheckIndex = m_data.indexOf(this.m_selectedFriends[0]);
            if(uncheckIndex >= m_tileSet * this.getNumSlots() && uncheckIndex < m_tileSet * this.getNumSlots() + this.getNumSlots())
            {
               tile = m_tiles[uncheckIndex - m_tileSet * this.getNumSlots()] as MovieClip;
               tile.checked = false;
               tile.gotoAndStop(1);
            }
            this.m_selectedFriends = new Array();
         }
         this.m_selectedFriends.push(m_data[index]);
      }
      
      protected function handleRemoveFriend(index:int) : void
      {
         var removeIndex:int = this.m_selectedFriends.indexOf(m_data[index]);
         this.m_selectedFriends.splice(removeIndex,1);
      }
      
      protected function errorPopupClose(event:Event) : void
      {
         this.m_errorPopup = null;
      }
      
      protected function onNextClick(event:MouseEvent) : void
      {
         if(this.m_checkMinMax)
         {
            if(this.m_selectedFriends.length >= this.minFriends && this.m_selectedFriends.length <= this.maxFriends)
            {
               this.closeFriendSelector(event);
            }
            else
            {
               this.displayErrorMessage();
            }
         }
         else if(this.m_selectedFriends.length > 0)
         {
            this.closeFriendSelector(event);
         }
         else if(this.m_errorPopup == null)
         {
            this.displayErrorMessage();
         }
      }
      
      protected function displayErrorMessage() : void
      {
         if(this.m_checkMinMax)
         {
            this.m_errorPopup = new GenericPopup(ZLocUtils.t("Dialogs","FriendSelectorRange",{
               "quantity":this.minFriends,
               "maximum":this.maxFriends
            }),GenericPopup.TYPE_OK,this.errorPopupClose);
         }
         else if(this.m_multiSelect)
         {
            this.m_errorPopup = new GenericPopup(ZLocUtils.t("Dialogs","NoFriendSelectedMulti"),GenericPopup.TYPE_OK,this.errorPopupClose);
         }
         else
         {
            this.m_errorPopup = new GenericPopup(ZLocUtils.t("Dialogs","NoFriendSelected"),GenericPopup.TYPE_OK,this.errorPopupClose);
         }
         this.m_errorPopup.setAcceptTextName("OkButton");
         UI.displayPopup(this.m_errorPopup,false);
      }
      
      public function closeDialog() : void
      {
         if(this.m_errorPopup)
         {
            this.m_errorPopup.close();
         }
         removeTiles(false);
         m_window.friendChooser_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         this.disableArrowButtons();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            this.removeComponent(compIdx);
            compIdx++;
         }
      }
      
      protected function closeFriendSelector(event:MouseEvent) : void
      {
         this.closeDialog();
         event.stopPropagation();
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         this.m_selectedFriends = new Array();
         this.closeDialog();
         event.stopPropagation();
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      public function get minFriends() : int
      {
         return this.m_minFriends;
      }
      
      public function get maxFriends() : int
      {
         return this.m_maxFriends;
      }
   }
}

