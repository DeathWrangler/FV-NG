package Display
{
   import Classes.EmbeddedArt;
   import Classes.IUser;
   import Classes.ValentinesBox;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Transactions.TRedeemCreditsItem;
   import fl.motion.easing.Quadratic;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import gs.TweenLite;
   
   public class ValentinesBoxDialog extends SlotDialog
   {
      
      private static const LOC_BUNDLE:String = "Dialogs";
      
      private static const VALENTINES_DIALOG_ASSET:String = "assets/dialogs/FV_ValentinesBox.swf";
      
      private static const HOW_DOES_THIS_WORK_UID:String = "ValentinesBox_howDoesThisWorkPopup";
      
      private static const PROGRESS_BT:String = "ProgressBt";
      
      private static const COMPARISON_BT:String = "ComparisonBt";
      
      private static const HOW_DOES_THIS_WORK_BT:String = "howDoesThisWorkBt";
      
      private static const ASK_FOR_LOVE_SHEEN_INTERVAL_MS:uint = 5000;
      
      private static const LOVE_METER_TWEEN_TIME:Number = 2;
      
      private static const LOVE_METER_HIGHEST_LEVEL_OFFSET:Number = 14.4;
      
      private static const LOVE_METER_VALENTINES_AT_TOP:uint = 200;
      
      private static const LOVE_METER_SHOW_STARS_THRESHOLD:uint = 150;
      
      private static const LOCKED_ITEM_ICON_URL:String = "assets/decorations/valetine_locked_icon.png";
      
      private static const LOCKED_ITEM_REDEEM_BUTTON_FRAME:uint = 4;
      
      private static const LEADERBOARD_SLOT_ICON_HEIGHT:Number = 39;
      
      private static const LEADERBOARD_SLOT_ICON_WIDTH:Number = 39;
      
      private static const LEADERBOARD_SLOT_ICON_OFFSET_X:Number = 1;
      
      private static const LEADERBOARD_SLOT_ICON_OFFSET_Y:Number = 1;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_HEIGHT:Number = 56;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_WIDTH:Number = 56;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_X:Number = 1.5;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_Y:Number = 2;
      
      private static const MODE_PROGRESS:uint = 0;
      
      private static const MODE_COMPARISON:uint = 1;
      
      private static const CENTER_ICON_VERTICAL_DISPLACE:Number = -50;
      
      private const FEATURE_NAME:String = "valentine";
      
      private const NUM_PROGRESS_SLOTS:int = 6;
      
      private const NUM_COMPARISON_SLOTS:int = 3;
      
      private var m_currentMode:uint = 0;
      
      private var m_howDoesThisWorkPopup:GenericPopup = null;
      
      private var m_buttons:Object = new Object();
      
      private var m_numValentines:uint = Global.player.getFeatureCredits(this.FEATURE_NAME);
      
      private var m_numValentinesReceived:uint = Global.player.getFeatureCreditsReceived(this.FEATURE_NAME);
      
      private var m_loveMeterBarFullHeight:Number = 0;
      
      private var m_showWhatIsThisDialogOnLoad:Boolean = false;
      
      private var m_valentinesBox:ValentinesBox = null;
      
      private var m_friends:Array = new Array();
      
      private var m_friendsRanking:uint = 0;
      
      private var m_loveLevelTitles:Array = new Array();
      
      private var m_askForLoveSheenTimer:Timer = new Timer(ASK_FOR_LOVE_SHEEN_INTERVAL_MS);
      
      public function ValentinesBoxDialog(valentinesBox:ValentinesBox, showWhatIsThisOnLoad:Boolean = false)
      {
         m_dialogAsset = VALENTINES_DIALOG_ASSET;
         this.m_valentinesBox = valentinesBox;
         this.m_showWhatIsThisDialogOnLoad = showWhatIsThisOnLoad;
         super();
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.addEventListeners();
         this.populateLoveLevelTitles();
         this.setupStaticUI();
         this.setupButtons();
         this.setupLoveMeter();
         this.setupLeaderboard();
         this.switchMode(MODE_PROGRESS);
         if(this.m_showWhatIsThisDialogOnLoad)
         {
            this.onHowDoesThisWorkClick();
         }
      }
      
      override protected function getNumSlots() : int
      {
         var numSlots:int = 0;
         if(this.m_currentMode == MODE_PROGRESS)
         {
            numSlots = this.NUM_PROGRESS_SLOTS;
         }
         else if(this.m_currentMode == MODE_COMPARISON)
         {
            numSlots = this.NUM_COMPARISON_SLOTS;
         }
         return numSlots;
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         if(Boolean(m_tiles && m_tiles[compId]) && Boolean(m_data) && Boolean(m_data[index + compId]))
         {
            if(this.m_currentMode == MODE_PROGRESS)
            {
               this.addProgressComponent(compId,index);
            }
            else if(this.m_currentMode == MODE_COMPARISON)
            {
               this.addComparisonComponent(compId,index);
            }
         }
      }
      
      private function addProgressComponent(compId:int, index:int) : void
      {
         var mc:MovieClip = m_tiles[compId] as MovieClip;
         var redeemItemData:Object = m_data[index + compId];
         if(redeemItemData.cost)
         {
            mc.costs_tf.visible = true;
            mc.costs_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_ItemCost",[redeemItemData.cost]);
         }
         if(redeemItemData.cost <= this.m_numValentines)
         {
            if(!this.m_buttons[compId])
            {
               this.m_buttons[compId] = new GenericButton(mc.redeem_bt,this.onRedeem);
               this.m_buttons[compId].text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Redeem");
            }
         }
         else
         {
            mc.redeem_bt.gotoAndStop(LOCKED_ITEM_REDEEM_BUTTON_FRAME);
         }
         var iconItemName:String = "";
         var itemNameText:String = "";
         if(this.m_numValentinesReceived >= redeemItemData.cost)
         {
            this.addItemIcon(redeemItemData.name,"icon",mc,mc.icon);
            itemNameText = ZLocUtils.tk_pk_asTitle(redeemItemData.friendlyName);
         }
         else
         {
            this.addIcon(Global.getAssetURL(LOCKED_ITEM_ICON_URL),mc,mc.icon);
            itemNameText = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_LockedItemName");
         }
         mc.itemTitle_tf.visible = true;
         mc.itemTitle_tf.text = itemNameText;
         mc.visible = true;
      }
      
      private function addComparisonComponent(compId:int, index:int) : void
      {
         var mc:MovieClip = m_tiles[compId] as MovieClip;
         var friendData:Object = m_data[index + compId];
         if(friendData.name)
         {
            mc.name_tf.text = friendData.name;
         }
         if(friendData.title)
         {
            mc.title_tf.text = friendData.title;
         }
         if(friendData.valentinesReceived != null)
         {
            mc.points_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Score",[friendData.valentinesReceived]);
         }
         if(friendData.uid)
         {
            this.addProfileIcon(friendData.uid,mc,mc.icon,LEADERBOARD_SLOT_ICON_WIDTH,LEADERBOARD_SLOT_ICON_HEIGHT,LEADERBOARD_SLOT_ICON_OFFSET_X,LEADERBOARD_SLOT_ICON_OFFSET_Y);
         }
         mc.visible = true;
      }
      
      private function pushNewData() : void
      {
         m_data = [];
         if(this.m_currentMode == MODE_PROGRESS)
         {
            this.pushNewProgressData();
         }
         else if(this.m_currentMode == MODE_COMPARISON)
         {
            this.pushNewComparisonData();
         }
      }
      
      private function pushNewProgressData() : void
      {
         var redeemItemXML:XML = null;
         var redeemItem:FarmItem = null;
         var redeemItemData:Object = null;
         var creditsXml:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.FEATURE_NAME);
         var redeemItemsXML:XMLList = new XMLList();
         if(Boolean(creditsXml) && Boolean(creditsXml.redeemItem))
         {
            redeemItemsXML = creditsXml.redeemItem;
         }
         var index:uint = 0;
         while(index < this.getNumSlots() && index < redeemItemsXML.length())
         {
            redeemItemXML = redeemItemsXML[index];
            redeemItem = Global.farmGameSettingsManager.getFarmItemByName(redeemItemXML.@name.toString());
            if(redeemItem)
            {
               redeemItemData = new Object();
               redeemItemData.name = redeemItem.name;
               redeemItemData.friendlyName = redeemItem.friendlyName;
               redeemItemData.cost = parseInt(redeemItemXML.@creditCost.toString());
               redeemItemData.icon = redeemItem.icon;
               m_data.push(redeemItemData);
            }
            index++;
         }
      }
      
      private function pushNewComparisonData() : void
      {
         var friend:IUser = null;
         var fullName:String = null;
         var creditsReceived:int = 0;
         var title:String = null;
         var friendData:Object = null;
         var friendPlayer:IUser = null;
         var index:int = 0;
         while(index < this.getNumSlots() && index < this.m_friends.length)
         {
            friend = this.m_friends[index];
            if(friend)
            {
               fullName = "";
               if(friend.uid == Global.player.snUser.uid)
               {
                  fullName = Global.player.snUser.name;
               }
               else
               {
                  friendPlayer = Global.friendManager.getFriendData(friend.uid);
                  if(friendPlayer)
                  {
                     fullName = friendPlayer.name;
                  }
               }
               creditsReceived = friend.getFeatureCreditsReceived(this.FEATURE_NAME);
               title = this.getLoveLevelTitle(creditsReceived);
               if(title)
               {
                  title = this.quoteTitle(title);
               }
               friendData = new Object();
               friendData.name = fullName;
               friendData.valentinesReceived = creditsReceived;
               friendData.title = title;
               friendData.uid = friend.uid;
               m_data.push(friendData);
            }
            index++;
         }
      }
      
      private function onClose(event:MouseEvent = null) : void
      {
         if(this.m_howDoesThisWorkPopup)
         {
            this.m_howDoesThisWorkPopup.close();
         }
         for(var index:uint = 0; index < this.m_buttons.length; index++)
         {
            if(this.m_buttons[index])
            {
               this.m_buttons[index].turnOff();
            }
         }
         removeTiles(false);
         this.removeEventListeners();
         if(event != null)
         {
            event.stopPropagation();
         }
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      private function addEventListeners() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt))
         {
            m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
         }
         if(this.m_askForLoveSheenTimer)
         {
            this.m_askForLoveSheenTimer.addEventListener(TimerEvent.TIMER,this.onPlayAskForLoveSheen);
         }
      }
      
      private function removeEventListeners() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt))
         {
            m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         }
         if(this.m_askForLoveSheenTimer)
         {
            this.m_askForLoveSheenTimer.removeEventListener(TimerEvent.TIMER,this.onPlayAskForLoveSheen);
         }
      }
      
      private function setupTiles() : void
      {
         var tile:String = null;
         m_tiles = new Array();
         for(var index:uint = 0; index < this.getNumSlots(); index++)
         {
            tile = "";
            if(this.m_currentMode == MODE_PROGRESS)
            {
               tile = "storagePanel" + (index + 1).toString();
               if(m_window.progress_mc.hasOwnProperty(tile))
               {
                  m_tiles[index] = m_window.progress_mc.getChildByName(tile);
               }
            }
            else
            {
               tile = "Leader" + (index + 1).toString() + "_mc";
               if(m_window.leaderBoard_mc.hasOwnProperty(tile))
               {
                  m_tiles[index] = m_window.leaderBoard_mc.getChildByName(tile);
                  this.initializeComparisonTile(m_tiles[index]);
               }
            }
         }
      }
      
      private function initializeComparisonTile(tile:MovieClip) : void
      {
         tile.name_tf.text = "";
         tile.title_tf.text = "";
         tile.points_tf.text = "";
      }
      
      private function setupButtons() : void
      {
         var howDoesThisWorkButton:GenericButton = new GenericButton(m_window.whatisthis_mc,this.onHowDoesThisWorkClick);
         howDoesThisWorkButton.text = ZLocUtils.t(LOC_BUNDLE,"HowDoesThisWork");
         this.m_buttons[HOW_DOES_THIS_WORK_BT] = howDoesThisWorkButton;
         var progressButton:GenericButton = new GenericButton(m_window.progress_bt,this.onProgressClick);
         progressButton.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Progress");
         progressButton.enableHitState(true);
         this.m_buttons[PROGRESS_BT] = progressButton;
         var comparisonButton:GenericButton = new GenericButton(m_window.comparison_bt,this.onComparisonClick);
         comparisonButton.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Comparison");
         comparisonButton.enableHitState(true);
         this.m_buttons[COMPARISON_BT] = comparisonButton;
      }
      
      private function setupStaticUI() : void
      {
         m_window.title_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Title");
         m_window.currentVal_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_NumValentines",[this.m_numValentines]);
         m_window.loveCompletion_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_TotalValentinesReceived",[this.m_numValentinesReceived]);
         if(m_window.progress_mc.loveMeter_mc)
         {
            m_window.progress_mc.loveMeter_mc.amount_tf.text = this.m_numValentinesReceived;
         }
         this.m_askForLoveSheenTimer.start();
      }
      
      private function setupLoveMeter() : void
      {
         var loveMeter_mc:MovieClip = null;
         var loveLevels:Array = null;
         var index:uint = 0;
         var bar:MovieClip = null;
         var incrementTextFieldName:String = null;
         var increment_tf:TextField = null;
         if(Boolean(m_window.progress_mc) && Boolean(m_window.progress_mc.loveMeter_mc))
         {
            loveMeter_mc = m_window.progress_mc.loveMeter_mc as MovieClip;
            if(loveMeter_mc.bar_mc)
            {
               bar = loveMeter_mc.bar_mc as MovieClip;
               this.m_loveMeterBarFullHeight = bar.height;
               bar.rotation += 180;
               bar.x += bar.width;
               bar.y += bar.height;
            }
            loveLevels = this.m_valentinesBox.getLevelCredits();
            for(index = 0; index < loveLevels.length; index++)
            {
               incrementTextFieldName = "increment" + (index + 1) + "_tf";
               if(loveMeter_mc.hasOwnProperty(incrementTextFieldName))
               {
                  increment_tf = loveMeter_mc.getChildByName(incrementTextFieldName) as TextField;
                  increment_tf.text = loveLevels[index];
               }
            }
            if(loveMeter_mc.loveMeterLabel_tf)
            {
               loveMeter_mc.loveMeterLabel_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_LoveMeterLabel");
            }
         }
      }
      
      private function addItemIcon(itemName:String, imageName:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0) : void
      {
         var url:String = Global.farmGameSettingsManager.getImageByName(itemName,imageName);
         this.addIcon(url,tile,movieClip,width,height,offsetX,offsetY);
      }
      
      private function addProfileIcon(uid:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0) : void
      {
         var friend:IUser = null;
         var iconUrl:String = "";
         if(uid == Global.player.snUser.uid.toString())
         {
            iconUrl = Global.player.snUser.picture;
         }
         else
         {
            friend = Global.friendManager.getFriendData(uid);
            if(friend)
            {
               iconUrl = friend.picture;
            }
         }
         var defaultIcon:DisplayObject = new EmbeddedArt.hud_no_profile_pic();
         this.addIcon(iconUrl,tile,movieClip,width,height,offsetX,offsetY,defaultIcon);
      }
      
      private function addIcon(url:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0, defaultIcon:DisplayObject = null) : void
      {
         var icon:Loader = null;
         if(url)
         {
            icon = LoadingManager.load(url,function(event:Event):void
            {
               var dispObj:* = null;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  dispObj = icon.content;
                  if(tile)
                  {
                     Utilities.removeAllChildren(movieClip);
                  }
                  dispObj.width = width;
                  dispObj.height = height;
                  dispObj.x += offsetX;
                  dispObj.y += offsetY;
                  movieClip.addChild(dispObj);
               }
            });
         }
         else if(defaultIcon)
         {
            defaultIcon.width = width;
            defaultIcon.height = height;
            defaultIcon.x += offsetX;
            defaultIcon.y += offsetY;
            movieClip.addChild(defaultIcon);
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event = null) : void
      {
         var msg:String = null;
         if(!this.m_howDoesThisWorkPopup)
         {
            msg = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_HowDoesThisWork");
            this.m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET_LRG);
            this.m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(this.m_howDoesThisWorkPopup,false,HOW_DOES_THIS_WORK_UID,true);
         }
      }
      
      private function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         this.m_howDoesThisWorkPopup = null;
      }
      
      private function onProgressClick(event:Event) : void
      {
         this.switchMode(MODE_PROGRESS);
      }
      
      private function onComparisonClick(event:Event) : void
      {
         this.switchMode(MODE_COMPARISON);
      }
      
      private function switchMode(mode:uint) : void
      {
         this.m_currentMode = mode;
         this.setupTiles();
         this.pushNewData();
         addAllComponents(0);
         var progressButton:GenericButton = this.m_buttons[PROGRESS_BT] as GenericButton;
         var comparisonButton:GenericButton = this.m_buttons[COMPARISON_BT] as GenericButton;
         if(this.m_currentMode == MODE_PROGRESS)
         {
            this.setProgressVisibility(true);
            this.setComparisonVisibility(false);
            progressButton.state = GenericButton.HITSTATE;
            comparisonButton.state = GenericButton.UPSTATE;
            this.refreshLoveMeter();
         }
         else if(this.m_currentMode == MODE_COMPARISON)
         {
            this.setProgressVisibility(false);
            this.setComparisonVisibility(true);
            progressButton.state = GenericButton.UPSTATE;
            comparisonButton.state = GenericButton.HITSTATE;
         }
      }
      
      private function setProgressVisibility(isVisible:Boolean) : void
      {
         m_window.progress_mc.visible = isVisible;
      }
      
      private function setComparisonVisibility(isVisible:Boolean) : void
      {
         m_window.leaderBoard_mc.visible = isVisible;
      }
      
      private function onRedeem(event:Event) : void
      {
         var gb:GenericButton = null;
         var redeemItemData:Object = null;
         var transaction:TRedeemCreditsItem = null;
         for(var index:uint = 0; index < this.getNumSlots(); index++)
         {
            gb = this.m_buttons[index] as GenericButton;
            if(Boolean(gb) && event.currentTarget.buttonPointer === gb)
            {
               redeemItemData = m_data[m_tileSet + index];
               transaction = new TRedeemCreditsItem(this.m_valentinesBox,redeemItemData.name,redeemItemData.cost);
               transaction.setCenterIconVerticalDisplace(CENTER_ICON_VERTICAL_DISPLACE);
               TransactionManager.addTransaction(transaction,true);
               Global.player.useFeatureCredits(this.FEATURE_NAME,redeemItemData.cost);
               Global.player.addGift(redeemItemData.name);
               this.onClose();
            }
         }
      }
      
      private function getCurrentValentineCompPct() : Number
      {
         var pct:Number = 0;
         var maxCredits:uint = this.getLoveMeterMaxValentines();
         if(maxCredits > 0)
         {
            pct = this.m_numValentinesReceived / maxCredits * 100;
         }
         if(pct > 100)
         {
            pct = 100;
         }
         return Math.round(pct);
      }
      
      private function getLoveMeterMaxValentines() : uint
      {
         var result:uint = 0;
         var creditsXml:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.FEATURE_NAME);
         if(creditsXml)
         {
            result = uint(creditsXml.@meterMaxCredits);
         }
         return result;
      }
      
      private function refreshLoveMeter() : void
      {
         this.displayLoveMeterTitle();
         this.animateLoveMeter();
      }
      
      private function displayLoveMeterTitle() : void
      {
         if(m_window.progress_mc.loveMeter_mc.title4_tf)
         {
            m_window.progress_mc.loveMeter_mc.title4_tf.text = this.getLoveLevelTitle(this.m_numValentinesReceived);
         }
         if(this.m_numValentinesReceived >= LOVE_METER_SHOW_STARS_THRESHOLD)
         {
            m_window.progress_mc.loveMeter_mc.stars_mc.visible = true;
         }
         else
         {
            m_window.progress_mc.loveMeter_mc.stars_mc.visible = false;
         }
      }
      
      private function animateLoveMeter() : void
      {
         m_window.progress_mc.loveMeter_mc.bar_mc.height = 0;
         var tweenToHeight:Number = this.calcLoveMeterHeight();
         TweenLite.to(m_window.progress_mc.loveMeter_mc.bar_mc,LOVE_METER_TWEEN_TIME,{
            "height":tweenToHeight,
            "ease":Quadratic.easeOut
         });
      }
      
      private function calcLoveMeterHeight() : Number
      {
         var requiredAmount:Number = NaN;
         var topIntervalHeight:Number = NaN;
         var loveMeterHeight:Number = 0;
         var loveLevels:Array = this.m_valentinesBox.getLevelCredits();
         var levelIntervalHeight:Number = (this.m_loveMeterBarFullHeight - LOVE_METER_HIGHEST_LEVEL_OFFSET) / loveLevels.length;
         var prevRequiredAmount:Number = 0;
         var isGreaterThanHighestLevel:Boolean = true;
         for(var levelIndex:uint = 0; levelIndex < loveLevels.length; levelIndex++)
         {
            requiredAmount = Number(loveLevels[levelIndex]);
            if(this.m_numValentinesReceived <= requiredAmount)
            {
               loveMeterHeight += (this.m_numValentinesReceived - prevRequiredAmount) / (requiredAmount - prevRequiredAmount) * levelIntervalHeight;
               isGreaterThanHighestLevel = false;
               break;
            }
            loveMeterHeight += levelIntervalHeight;
            prevRequiredAmount = requiredAmount;
         }
         if(isGreaterThanHighestLevel)
         {
            topIntervalHeight = this.m_loveMeterBarFullHeight - (this.m_loveMeterBarFullHeight - LOVE_METER_HIGHEST_LEVEL_OFFSET);
            loveMeterHeight += (this.m_numValentinesReceived - prevRequiredAmount) / (LOVE_METER_VALENTINES_AT_TOP - prevRequiredAmount) * topIntervalHeight;
         }
         return loveMeterHeight;
      }
      
      private function setupLeaderboard() : void
      {
         this.populateFriends();
         this.setupPlayerPanel();
         this.setupShareLovePanel();
      }
      
      private function setupPlayerPanel() : void
      {
         var playerPanel:MovieClip = null;
         if(Boolean(m_window.leaderBoard_mc) && Boolean(m_window.leaderBoard_mc.playerPanel_mc))
         {
            playerPanel = m_window.leaderBoard_mc.playerPanel_mc as MovieClip;
            playerPanel.name_tf.text = Global.player.snUser.name;
            playerPanel.points_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Score",{"quantity":this.m_numValentinesReceived});
            playerPanel.title_tf.text = this.quoteTitle(this.getLoveLevelTitle(this.m_numValentinesReceived));
            playerPanel.rank_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Ranking",{
               "quantity":this.m_friendsRanking,
               "maximum":this.m_friends.length
            });
            this.addProfileIcon(Global.player.snUser.uid.toString(),playerPanel,playerPanel.icon,LEADERBOARD_PLAYER_PANEL_ICON_WIDTH,LEADERBOARD_PLAYER_PANEL_ICON_HEIGHT,LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_X,LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_Y);
         }
      }
      
      private function setupShareLovePanel() : void
      {
         var sharePanel_mc:MovieClip = null;
         var postButton:GenericButton = null;
         if(Boolean(m_window.leaderBoard_mc) && Boolean(m_window.leaderBoard_mc.sharePanel_mc))
         {
            sharePanel_mc = m_window.leaderBoard_mc.sharePanel_mc as MovieClip;
            sharePanel_mc.shareTitle_tf.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_ShareTheLove_Title");
            sharePanel_mc.share_tf.text = "";
            postButton = new GenericButton(sharePanel_mc.post_bt,this.onShareLove);
            postButton.text = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_ShareTheLove_Button");
         }
      }
      
      private function populateFriends() : void
      {
         var curFriend:IUser = null;
         var friends:Array = Global.friendManager.neighbors.concat();
         friends.push(Global.player);
         friends.sort(this.sortFriendsByCreditsReceived);
         for(var sortedIndex:uint = 0; sortedIndex < friends.length; sortedIndex++)
         {
            curFriend = friends[sortedIndex];
            if(curFriend.uid == Global.player.snUser.uid)
            {
               this.m_friendsRanking = sortedIndex + 1;
               break;
            }
         }
         this.m_friends = friends;
      }
      
      private function sortFriendsByCreditsReceived(friend1:IUser, friend2:IUser) : int
      {
         var result:int = 0;
         var featureName:String = this.FEATURE_NAME;
         var credits1:int = friend1.getFeatureCreditsReceived(featureName);
         var credits2:int = friend2.getFeatureCreditsReceived(featureName);
         if(credits1 > credits2)
         {
            result = -1;
         }
         else if(credits2 > credits1)
         {
            result = 1;
         }
         return result;
      }
      
      private function populateLoveLevelTitles() : void
      {
         var loveLevels:Array = this.m_valentinesBox.getLevelCredits();
         for(var index:uint = 0; index < loveLevels.length; index++)
         {
            this.m_loveLevelTitles[index] = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Level_" + (index + 1));
         }
      }
      
      private function getLoveLevelTitle(numValentinesReceived:uint) : String
      {
         var title:String = "";
         var loveLevels:Array = this.m_valentinesBox.getLevelCredits();
         for(var index:uint = 0; index < loveLevels.length; index++)
         {
            if(numValentinesReceived >= loveLevels[index])
            {
               title = this.m_loveLevelTitles[index];
            }
         }
         if(!title)
         {
            title = ZLocUtils.t(LOC_BUNDLE,"ValentinesBox_Level_0");
         }
         return title;
      }
      
      private function quoteTitle(title:String) : String
      {
         return "\"" + title + "\"";
      }
      
      private function onPlayAskForLoveSheen(event:TimerEvent) : void
      {
         var sheen_mc:MovieClip = null;
         if(m_window.sheen_mc)
         {
            sheen_mc = m_window.sheen_mc as MovieClip;
            sheen_mc.play();
         }
      }
      
      private function onShareLove(event:MouseEvent) : void
      {
      }
   }
}

