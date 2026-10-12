package Widgets.Windows
{
   import Classes.Constants.QuestConstants;
   import Classes.Friend;
   import Classes.Growable.GrowableContest;
   import Classes.GrowableAnimal;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.UserRewardUtil;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenLite;
   import com.greensock.easing.Elastic;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GrowableContestResultsWindow extends FarmWindow
   {
      
      private static const DEFAULT_WINDOW_ASSET:String = "assets/dialogs/FV_SocialPig_WeighIn.swf";
      
      private static const MAX_WEIGHT:int = 800;
      
      private var m_contest:GrowableContest;
      
      private var m_data:Object;
      
      private var m_resultsData:Object;
      
      private var m_playerIcon:FarmIcon;
      
      private var m_friendIcon:FarmIcon;
      
      private var m_scoreTextField:ZwTextField;
      
      private var m_scaleWidget:ZwWidget;
      
      private var m_arrowWidget:ZwWidget;
      
      private var m_tellButton:FarmAnimatedTextButton;
      
      private var m_interstitialWidget:ZwWidget;
      
      private var m_tipTextField:ZwTextField;
      
      private var m_timeTextField:ZwTextField;
      
      private var m_friendBonus:ZwTextField;
      
      private var m_feedBonus:ZwTextField;
      
      private var m_myName:ZwTextField;
      
      private var m_friendName:ZwTextField;
      
      private var m_friendBackground:ZwWidget;
      
      private var m_objectPreview:ObjectPreviewFrame;
      
      private var m_fakeMapResource:GrowableAnimal;
      
      public function GrowableContestResultsWindow(contest:GrowableContest, data:Object)
      {
         this.m_contest = contest;
         this.m_data = data;
         var windowAssetRelUrl:String = null;
         if(contest)
         {
            windowAssetRelUrl = contest.getAssetUrl(GrowableContest.ASSET_KEY_RESULTS_WINDOW);
         }
         if(!windowAssetRelUrl)
         {
            windowAssetRelUrl = DEFAULT_WINDOW_ASSET;
         }
         super(windowAssetRelUrl);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var farmItem:FarmItem = null;
         super.onLoadComplete(event);
         var element:MovieClip = m_window["weighIn_mc"];
         var entry:Object = this.m_contest.getContestEntryForKey(this.m_data["storageKey"],GrowableContest.CONTEST_LIST_PARTICIPATING);
         addWidget(new ZwWidget(element));
         if(ObjectUtil.pathExists(element,"friend_tf"))
         {
            addWidget(new ZwTextField(element.friend_tf),false);
         }
         var partnerUid:String = entry.partner;
         var friend:Friend = null;
         if(partnerUid)
         {
            friend = Global.friendManager.getFriendData(partnerUid);
            if(ObjectUtil.pathExists(element,"friend_tf"))
            {
               this.m_friendBonus = getWidget(element.friend_tf) as ZwTextField;
            }
         }
         if(ObjectUtil.pathExists(m_window,"title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,this.m_contest.getZLocString("Dialogs","Rewards_Title")));
         }
         if(ObjectUtil.pathExists(element,"myImage_mc"))
         {
            this.m_playerIcon = new FarmIcon(element["myImage_mc"],Global.player.picture);
            addWidget(this.m_playerIcon);
            this.m_playerIcon.visible = true;
         }
         if(ObjectUtil.pathExists(element,"myName_mc"))
         {
            this.m_myName = new ZwTextField(element["myName_mc"],Global.player.name);
            addWidget(this.m_myName);
            this.m_myName.visible = true;
         }
         if(ObjectUtil.pathExists(element,"friendImage_mc"))
         {
            this.m_friendIcon = new FarmIcon(element["friendImage_mc"],friend ? friend.picture : null);
            addWidget(this.m_friendIcon);
            this.m_friendIcon.visible = friend != null;
         }
         if(ObjectUtil.pathExists(element,"friendName_mc"))
         {
            this.m_friendName = new ZwTextField(element["friendName_mc"],friend ? friend.name : "");
            addWidget(this.m_friendName);
            this.m_friendName.visible = friend != null;
         }
         if(ObjectUtil.pathExists(element,"friendBack_mc"))
         {
            this.m_friendBackground = new ZwWidget(element["friendBack_mc"]);
            addWidget(this.m_friendBackground);
            this.m_friendBackground.visible = friend != null;
         }
         if(ObjectUtil.pathExists(element,"pounds_tf"))
         {
            this.m_scoreTextField = new ZwTextField(element["pounds_tf"],"0");
            addWidget(this.m_scoreTextField);
            this.m_scoreTextField.visible = false;
         }
         if(ObjectUtil.pathExists(element,"scale_mc"))
         {
            this.m_scaleWidget = addWidget(new ZwWidget(element["scale_mc"])) as ZwWidget;
            if(ObjectUtil.pathExists(element["scale_mc"],"arrow_mc"))
            {
               this.m_arrowWidget = addWidget(new ZwWidget(element["scale_mc"]["arrow_mc"])) as ZwWidget;
               this.m_arrowWidget.element.gotoAndStop(0);
            }
         }
         if(ObjectUtil.pathExists(m_window,"interstitial_mc"))
         {
            this.m_interstitialWidget = new ZwWidget(m_window.interstitial_mc);
            addWidget(this.m_interstitialWidget);
            this.m_interstitialWidget.visible = true;
            this.m_interstitialWidget.element.play();
         }
         this.m_fakeMapResource = new GrowableAnimal();
         if(this.m_data.hasOwnProperty("code") && Boolean(this.m_data["code"]))
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data["code"]);
            this.m_fakeMapResource.setItem(farmItem);
            this.m_fakeMapResource.attachToPersistentData(this.m_data["storageKey"]);
            this.m_fakeMapResource.setState(farmItem.getPreviewState());
            this.m_fakeMapResource.createDisplayObject();
            this.m_objectPreview = new ObjectPreviewFrame(m_window["weighIn_mc"].pig_mc,farmItem,null,[this.m_contest.objectPreviewScale],null,"","",this.m_fakeMapResource) as ObjectPreviewFrame;
            addWidget(this.m_objectPreview);
         }
         if(ObjectUtil.pathExists(element,"tell_bt"))
         {
            this.m_tellButton = new FarmAnimatedTextButton(element.tell_bt,this.m_contest.getZLocString("Dialogs","Rewards_Tell"),this.handleTellFriendsButtonClicked);
            addWidget(this.m_tellButton);
            this.toggleButton(this.m_tellButton,this.m_contest.canPostFeed(GrowableContest.FEED_TYPE_COMPLETE,null,this.m_data["storageKey"]));
         }
         if(ObjectUtil.pathExists(element,"amazing_tf"))
         {
            addWidget(new ZwTextField(element.amazing_tf,""),false);
         }
         if(ObjectUtil.pathExists(element,"description_tf"))
         {
            this.m_tipTextField = new ZwTextField(element.description_tf,this.m_contest.getZLocString("Dialogs","Rewards_Waiting"));
            addWidget(this.m_tipTextField);
         }
         if(ObjectUtil.pathExists(element,"time_tf"))
         {
            this.m_timeTextField = new ZwTextField(element.time_tf,this.m_fakeMapResource.totalGrowingTime);
            addWidget(this.m_timeTextField,false);
         }
         if(ObjectUtil.pathExists(element,"feed_tf"))
         {
            this.m_feedBonus = new ZwTextField(element.feed_tf);
            addWidget(this.m_feedBonus);
         }
         if(ObjectUtil.pathExists(element,"rewards_mc"))
         {
            if(ObjectUtil.pathExists(element["rewards_mc"],"effect0_mc"))
            {
               element["rewards_mc"]["effect0_mc"].visible = false;
            }
            if(ObjectUtil.pathExists(element["rewards_mc"],"effect1_mc"))
            {
               element["rewards_mc"]["effect1_mc"].visible = false;
            }
            if(ObjectUtil.pathExists(element["rewards_mc"],"effect2_mc"))
            {
               element["rewards_mc"]["effect2_mc"].visible = false;
            }
         }
         m_closeButton.visible = false;
         this.m_scaleWidget.visible = true;
         if(this.m_resultsData)
         {
            this.showResults();
         }
         else
         {
            this.m_interstitialWidget.element.play();
         }
      }
      
      private function setupFeedBonus() : void
      {
         if(this.m_feedBonus)
         {
            this.m_feedBonus.text = this.m_contest.getZLocString("Dialogs","Feed_Bonus",{"amount":this.getFeedBonus().toString()});
         }
      }
      
      private function setupTimeBonus() : void
      {
         if(this.m_timeTextField)
         {
            this.m_timeTextField.text = this.m_contest.getZLocString("Dialogs","Time_Bonus",{"amount":this.getTimeBonus().toString()});
         }
      }
      
      private function setupModifiedBonus() : void
      {
         if(this.m_friendBonus)
         {
            this.m_friendBonus.text = this.m_contest.getZLocString("Dialogs","Partner_Bonus",{"amount":this.getModifierBonus().toString()});
         }
      }
      
      private function getTimeBonus() : int
      {
         var timeBonus:int = 0;
         var contestTime:Number = this.m_fakeMapResource.fixedTime ? this.m_fakeMapResource.fixedTime : GlobalEngine.serverTime / 1000;
         var timeRemaining:Number = Number(this.m_fakeMapResource.stopGrowingTime) - contestTime;
         if(timeRemaining > 0)
         {
            if(this.m_friendBonus)
            {
               timeBonus = Math.floor(timeRemaining / this.m_contest.getMaxAge() + 1);
               timeBonus = this.getFeedBonus() * timeBonus / 2.5;
            }
            else
            {
               timeBonus = this.m_resultsData.score - this.getFeedBonus();
            }
         }
         return timeBonus;
      }
      
      private function getFeedBonus() : int
      {
         return 5 + 3 * this.m_fakeMapResource.totalFedCount;
      }
      
      private function getModifierBonus() : int
      {
         return this.m_resultsData.score - this.getFeedBonus() - this.getTimeBonus();
      }
      
      override public function show() : void
      {
         super.show();
         this.statCount("impressions");
      }
      
      override public function close() : void
      {
         super.close();
         GrowableContestWindow.showWindowForContest(this.m_contest);
         this.statCount("close");
      }
      
      override protected function release() : void
      {
         this.m_playerIcon = null;
         this.m_friendIcon = null;
         this.m_scoreTextField = null;
         this.m_scaleWidget = null;
         this.m_arrowWidget = null;
         this.m_tellButton = null;
         this.m_interstitialWidget = null;
         this.m_tipTextField = null;
         this.m_timeTextField = null;
         this.m_friendBonus = null;
         this.m_feedBonus = null;
         this.m_objectPreview = null;
         this.m_fakeMapResource = null;
         super.release();
      }
      
      public function resultsCallback(data:Object) : void
      {
         this.m_resultsData = data;
         if(this.isLoaded())
         {
            this.showResults();
         }
      }
      
      private function showResults() : void
      {
         this.setupFeedBonus();
         if(this.m_friendBonus)
         {
            this.setupModifiedBonus();
         }
         this.setupTimeBonus();
         this.m_interstitialWidget.visible = false;
         this.m_scoreTextField.visible = true;
         var scorepercentage:int = this.m_resultsData.score / MAX_WEIGHT * 100;
         var obj:Object = {
            "x":0,
            "score":0
         };
         TweenLite.to(obj,5,{
            "x":scorepercentage,
            "score":this.m_resultsData.score,
            "ease":Elastic.easeOut,
            "onUpdate":this.tweenFunction(obj),
            "onComplete":this.onPercentageTweenComplete
         });
      }
      
      private function showRewards() : void
      {
         if(this.m_timeTextField)
         {
            this.m_timeTextField.visible = true;
         }
         if(this.m_friendBonus)
         {
            this.m_friendBonus.visible = true;
         }
         if(this.m_feedBonus)
         {
            this.m_feedBonus.visible = true;
         }
         if(this.m_fakeMapResource.totalFedCount < 100)
         {
            this.m_tipTextField.text = this.m_contest.getZLocString("Dialogs","Rewards_Time");
         }
         else
         {
            this.m_tipTextField.text = this.m_contest.getZLocString("Dialogs","Rewards_MaxFed");
         }
         this.setupRewards();
      }
      
      private function onPercentageTweenComplete() : void
      {
         this.showRewards();
         m_closeButton.visible = true;
      }
      
      private function tweenFunction(obj:Object) : Function
      {
         return function():void
         {
            var frame:* = int(obj.x);
            if(m_arrowWidget != null && m_arrowWidget.element != null)
            {
               m_arrowWidget.element.gotoAndStop(frame);
               m_scoreTextField.text = "" + int(obj.score) + " " + m_contest.getZLocString("Dialogs","Rewards_Units");
            }
         };
      }
      
      private function setupRewards() : void
      {
         var icon:FarmIcon = null;
         var index:int = 0;
         var reward:Object = null;
         var itemCode:String = null;
         var itemName:String = null;
         var itemQuantity:int = 0;
         var item:FarmItem = null;
         var rewardsMC:MovieClip = m_window["weighIn_mc"]["rewards_mc"];
         var rewards:Array = this.m_resultsData.reward;
         if(rewards)
         {
            UserRewardUtil.grantUserRewards(Vector.<Object>(rewards),false);
            for(index = 0; index < rewards.length; index++)
            {
               reward = rewards[index];
               if(Boolean(rewardsMC["reward" + index + "_tf"]) && Boolean(rewardsMC["rewardImage" + index + "_mc"]) && Boolean(reward))
               {
                  itemCode = null;
                  itemName = null;
                  itemQuantity = 0;
                  switch(reward.type)
                  {
                     case QuestConstants.REWARD_COINS:
                        itemCode = "9a";
                        itemName = "Coins";
                        itemQuantity = int(reward.value);
                        break;
                     case QuestConstants.REWARD_XP:
                        itemCode = "A2";
                        itemName = "XP";
                        itemQuantity = int(reward.quantity);
                        break;
                     case QuestConstants.REWARD_GRANT_ITEM:
                        itemCode = reward.value;
                        itemQuantity = int(reward.quantity);
                  }
                  if(itemCode != null)
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                     if(item)
                     {
                        icon = new FarmIcon(rewardsMC["rewardImage" + index + "_mc"],item.iconUrl);
                        if(itemName == null)
                        {
                           itemName = item.friendlyTitle;
                        }
                        if(itemQuantity > 1)
                        {
                           itemName = itemQuantity + " " + itemName;
                        }
                        icon.attachTooltip(new FarmTextTooltip(itemName));
                        rewardsMC["reward" + index + "_tf"].text = itemName;
                        addWidget(icon,true);
                        rewardsMC["effect" + index + "_mc"].visible = true;
                        rewardsMC["effect" + index + "_mc"].play();
                     }
                  }
               }
            }
         }
      }
      
      private function handleTellFriendsButtonClicked(e:Event) : void
      {
         this.m_contest.postGeneralFeed(GrowableContest.FEED_TYPE_COMPLETE,this.handleTellFriendButtonCallback,null,this.m_data["storageKey"]);
         this.toggleButton(this.m_tellButton,false);
         this.statCount("share");
      }
      
      private function handleTellFriendButtonCallback(data:Object) : void
      {
         this.close();
      }
      
      public function statCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         this.m_contest.statCount("reward_dialog",phylum,zclass,family,genus,value);
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
   }
}

