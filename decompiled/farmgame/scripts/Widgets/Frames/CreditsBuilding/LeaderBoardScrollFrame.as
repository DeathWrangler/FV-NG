package Widgets.Frames.CreditsBuilding
{
   import Classes.Friend;
   import Classes.IUser;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.TrickOrTreatManager;
   import Transactions.TTrickOrTreatPassNeighbor;
   import Transactions.TTrickOrTreatRedeemReward;
   import Transactions.TTrickOrTreatStartProgress;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.easing.Quad;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class LeaderBoardScrollFrame extends ZwFrame
   {
      
      private static const SLOT_ICON_SIZE:int = 50;
      
      private static const SLOT_VOFFSET:int = 2;
      
      private static const MIN_SLOTS_VISIBLE:int = 3;
      
      public static const FIRST_INTERACTION:String = "FirstInteraction";
      
      private var m_friendSlot:MovieClip;
      
      private var m_featureCreditName:String;
      
      private var m_arrowUp:ZwButton;
      
      private var m_arrowDown:ZwButton;
      
      private var m_friendsContainer:MovieClip;
      
      private var m_minScroll:Number = 0;
      
      private var m_maxScroll:Number = 0;
      
      private var m_slotHeight:int = 0;
      
      private var m_latestReward:String;
      
      private var m_rewardLink:String;
      
      private var m_statsSubcounter:String;
      
      private var m_enableAnimation:Boolean = true;
      
      public function LeaderBoardScrollFrame(element:DisplayObject, friendSlot:MovieClip, featureCreditName:String)
      {
         var startLicenses:Number = NaN;
         var i:int = 0;
         super(element);
         this.m_statsSubcounter = !Global.player.getSeenFlag(TrickOrTreatManager.instance.featureCreditName + LeaderBoardScrollFrame.FIRST_INTERACTION) ? " first_main_dialog" : "return_main_dialog";
         this.m_friendSlot = friendSlot;
         this.m_featureCreditName = featureCreditName;
         if(this.m_friendSlot)
         {
            addWidget(new ZwBaseWidget(this.m_friendSlot),false);
         }
         if(m_element.friendsContainer_mc != null)
         {
            this.m_friendsContainer = m_element.friendsContainer_mc as MovieClip;
         }
         addWidget(this.m_arrowUp = new ZwButton(m_element.arrowUp_bt,this.onScrollUp));
         addWidget(this.m_arrowDown = new ZwButton(m_element.arrowDown_bt,this.onScrollDown));
         this.m_arrowUp.enabled = false;
         this.populateLeaderBoard();
         if(!Global.player.getSeenFlag(TrickOrTreatManager.instance.featureName + FIRST_INTERACTION) && !TrickOrTreatManager.instance.isOffBoarding())
         {
            startLicenses = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getNumberConstant("startLicenses");
            for(i = 0; i < startLicenses; i++)
            {
               Global.player.incAltGraphicCredits(TrickOrTreatManager.instance.altGraphicCreditName);
            }
            TrickOrTreatManager.instance.updateTotalTrickLicenses();
            TransactionManager.addTransaction(new TTrickOrTreatStartProgress(this.m_featureCreditName,function(result:Object):void
            {
               TrickOrTreatManager.instance.shareDialog(result);
            }));
            Global.player.setSeenFlag(TrickOrTreatManager.instance.featureName + FIRST_INTERACTION);
         }
         if(TrickOrTreatManager.instance.isOffBoarding())
         {
            if(!Global.player.getSeenFlag(TrickOrTreatManager.instance.featureCreditName + TrickOrTreatManager.TOKEN_OFFBOARDING))
            {
               TrickOrTreatManager.instance.offBoardUser();
               Global.player.setSeenFlag(TrickOrTreatManager.instance.featureCreditName + TrickOrTreatManager.TOKEN_OFFBOARDING);
            }
         }
      }
      
      private function populateLeaderBoard() : void
      {
         var communityNeighborsSlot:Friend;
         var rewards:Array;
         var rank:int;
         var playerFound:Boolean;
         var playerPosition:int;
         var passedNeighbor:String;
         var scrollTime:Number;
         var object:Object = null;
         var friendsContainer:ZwFrame = null;
         var FriendSlotClass:Class = null;
         var friendSlotInstance:MovieClip = null;
         var i:int = 0;
         var unlockedRewards:Array = null;
         var fireTransaction:Boolean = false;
         var rewardName:String = null;
         var throttleTime:Number = NaN;
         var lastPassNeighbor:Number = NaN;
         var timeDifference:Number = NaN;
         var leaderBoardSlots:Array = Global.friendManager.neighbors.concat();
         var communityNeighborMetadata:Object = new Object();
         communityNeighborMetadata.uid = -1;
         communityNeighborMetadata.featureCredits = new Object();
         communityNeighborMetadata.featureCredits[Global.worldManager.currentWorldType] = new Object();
         communityNeighborMetadata.featureCredits[Global.worldManager.currentWorldType][TrickOrTreatManager.instance.featureCreditName] = new Object();
         communityNeighborMetadata.featureCredits[Global.worldManager.currentWorldType][TrickOrTreatManager.instance.featureCreditName]["received"] = -1;
         communityNeighborsSlot = new Friend(communityNeighborMetadata,null,true,true);
         leaderBoardSlots.push(communityNeighborsSlot);
         leaderBoardSlots.push(Global.player);
         rewards = TrickOrTreatManager.instance.getRewards();
         for each(object in rewards)
         {
            leaderBoardSlots.push(object);
         }
         leaderBoardSlots.sort(this.sortFriendsByStatCount);
         friendsContainer = new ZwFrame(m_element.friendsContainer_mc as MovieClip);
         addWidget(friendsContainer);
         FriendSlotClass = Object(this.m_friendSlot).constructor;
         friendSlotInstance = new FriendSlotClass() as MovieClip;
         this.m_slotHeight = friendSlotInstance.height + SLOT_VOFFSET;
         this.m_minScroll = 0;
         this.m_maxScroll = Math.max(0,this.m_slotHeight * (leaderBoardSlots.length - MIN_SLOTS_VISIBLE));
         for(i = 0; i < leaderBoardSlots.length; i++)
         {
            friendSlotInstance = new FriendSlotClass() as MovieClip;
            friendSlotInstance.name = "slotName_" + i.toString();
            m_element.friendsContainer_mc["slot_" + i] = friendSlotInstance;
            (m_element.friendsContainer_mc as MovieClip).addChild(friendSlotInstance);
            friendSlotInstance.y = (friendSlotInstance.height + SLOT_VOFFSET) * i;
         }
         rank = 0;
         playerFound = false;
         playerPosition = 0;
         unlockedRewards = new Array();
         passedNeighbor = "0";
         if(m_element.friendsContainer_mc != null)
         {
            for(i = 0; i < leaderBoardSlots.length; i++)
            {
               if(leaderBoardSlots[i].hasOwnProperty("uid"))
               {
                  rank++;
                  if(leaderBoardSlots[i].uid != Global.player.uid && passedNeighbor == "0" && Global.player.getFeatureCredits(this.m_featureCreditName) >= this.evaluateRank(leaderBoardSlots[i]))
                  {
                     passedNeighbor = leaderBoardSlots[i].uid as String;
                  }
                  else if(leaderBoardSlots[i].uid == Global.player.uid)
                  {
                     playerFound = true;
                  }
               }
               else if(Global.player.getFeatureCredits(this.m_featureCreditName) >= this.evaluateRank(leaderBoardSlots[i]) && !Global.player.getSeenFlag(this.m_featureCreditName + "_" + leaderBoardSlots[i].name))
               {
                  unlockedRewards.push(leaderBoardSlots[i].name);
               }
               if(!playerFound)
               {
                  playerPosition++;
               }
               this.setUpLeaderBoardSlot(m_element.friendsContainer_mc["slot_" + i],leaderBoardSlots[i],rank);
            }
         }
         playerPosition = Math.max(0,playerPosition - 2);
         scrollTime = Math.min(playerPosition * 0.25,3);
         this.m_enableAnimation = false;
         this.m_minScroll += this.m_slotHeight * playerPosition;
         this.m_maxScroll -= this.m_slotHeight * playerPosition;
         if(this.m_maxScroll <= 0)
         {
            this.m_arrowDown.enabled = false;
         }
         this.m_arrowUp.enabled = true;
         TweenLite.to(this.m_friendsContainer,scrollTime,{
            "y":this.m_friendsContainer.y - this.m_slotHeight * playerPosition,
            "ease":Quad.easeIn,
            "onComplete":function():void
            {
               m_enableAnimation = true;
            }
         });
         if(unlockedRewards.length > 0)
         {
            fireTransaction = false;
            for each(rewardName in unlockedRewards)
            {
               FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,this.m_statsSubcounter,"prize",rewardName);
               Global.player.setSeenFlag(this.m_featureCreditName + "_" + rewardName,false,true);
               Global.player.addGift(rewardName);
            }
            TransactionManager.addTransaction(new TTrickOrTreatRedeemReward(this.m_featureCreditName,function(result:Object):void
            {
               TrickOrTreatManager.instance.shareDialog(result);
            }));
         }
         if(passedNeighbor != "0")
         {
            throttleTime = FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).getNumberConstant("passShareDelay");
            lastPassNeighbor = Global.player.getFeatureLastShown(TrickOrTreatManager.instance.featureCreditName + TrickOrTreatManager.TOKEN_PASS_NEIGHBOR);
            timeDifference = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastPassNeighbor;
            if(timeDifference > throttleTime)
            {
               TransactionManager.addTransaction(new TTrickOrTreatPassNeighbor(this.m_featureCreditName,passedNeighbor,function(result:Object):void
               {
                  TrickOrTreatManager.instance.shareDialog(result);
                  Global.player.setFeatureLastShown(TrickOrTreatManager.instance.featureCreditName + TrickOrTreatManager.TOKEN_PASS_NEIGHBOR,GlobalEngine.serverTime,false);
               }));
               Global.player.setFeatureLastShown(TrickOrTreatManager.instance.featureCreditName + TrickOrTreatManager.TOKEN_PASS_NEIGHBOR,GlobalEngine.currentTime,true);
            }
         }
      }
      
      private function setUpLeaderBoardSlot(element:MovieClip, obj:Object, rank:int) : void
      {
         var profilePic:FarmIcon = null;
         var offboardingPrizes:Array = null;
         var prizeItem:FarmItem = null;
         var prizeIcon:FarmIcon = null;
         var friendSlotText:String = null;
         var visitButton:FarmAnimatedTextButton = null;
         var farmItem:FarmItem = null;
         var icon:FarmIcon = null;
         var remainingCost:Number = NaN;
         var slotFrame:ZwFrame = new ZwFrame(element);
         if(obj.hasOwnProperty("uid"))
         {
            if(obj.uid != -1)
            {
               slotFrame.addWidget(new ZwBaseWidget(element.neighbor_mc),false);
               slotFrame.addWidget(new FarmAnimatedButton(element.neighbor_mc.findNeighbor_bt),false);
               profilePic = new FarmIcon(element.icon_mc,obj.picture);
               profilePic.setIconSize(SLOT_ICON_SIZE,SLOT_ICON_SIZE);
               slotFrame.addWidget(profilePic);
               slotFrame.addWidget(new ZwTextField(element.rank_tf,rank.toString()));
               slotFrame.addWidget(new ZwTextField(element.name_tf,obj.name));
               offboardingPrizes = TrickOrTreatManager.instance.getOffBoardingPrizes();
               if(offboardingPrizes[rank - 1] != null)
               {
                  prizeItem = Global.farmGameSettingsManager.getFarmItemByName(offboardingPrizes[rank - 1]);
                  prizeIcon = new FarmIcon(element.trophy_mc,prizeItem.icon);
                  prizeIcon.setIconSize(SLOT_ICON_SIZE,SLOT_ICON_SIZE);
                  prizeIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",TrickOrTreatManager.instance.featureCreditName + "TrophyTooltip",{
                     "rank":ZLocUtils.formatNumber(rank),
                     "trophyName":ZLocUtils.tk_pk_asTitle(prizeItem.friendlyName)
                  })));
                  slotFrame.addWidget(prizeIcon);
                  slotFrame.addWidget(new ZwBaseWidget(element.burst_mc));
               }
               else
               {
                  slotFrame.addWidget(new ZwBaseWidget(element.burst_mc),false);
               }
               slotFrame.addWidget(new ZwTextField(element.points_tf,ZLocUtils.t("Dialogs","trickortreatNeighborTricksPlayed",{"count":this.evaluateRank(obj).toString()})));
               if(obj.uid == Global.player.snUser.uid)
               {
                  slotFrame.addWidget(new ZwBaseWidget(element.playerBackground_mc));
                  slotFrame.addWidget(new ZwBaseWidget(element.friendBackground_mc),false);
                  slotFrame.addWidget(new FarmAnimatedTextButton(element.playTrick_bt,"",null),false);
               }
               else
               {
                  slotFrame.addWidget(new ZwBaseWidget(element.friendBackground_mc));
                  slotFrame.addWidget(new ZwBaseWidget(element.playerBackground_mc),false);
                  friendSlotText = "";
                  if(!TrickOrTreatManager.instance.isOffBoarding())
                  {
                     friendSlotText = ZLocUtils.t("Dialogs","trickortreatNeighborPlayTrick");
                  }
                  else
                  {
                     friendSlotText = ZLocUtils.t("Dialogs","message_center_visit");
                  }
                  visitButton = new FarmAnimatedTextButton(element.playTrick_bt,friendSlotText,function():void
                  {
                     FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,m_statsSubcounter,"play_trick");
                     if(TrickOrTreatManager.instance.trickOrTreatDialog != null)
                     {
                        TrickOrTreatManager.instance.trickOrTreatDialog.close();
                     }
                     Global.worldManager.visitNeighbor(obj.uid.toString());
                  });
                  if(VisitorManager.getInstance().visitedUserId == obj.uid.toString())
                  {
                     visitButton.enabled = false;
                  }
                  slotFrame.addWidget(visitButton);
               }
            }
            else
            {
               slotFrame.addWidget(new ZwBaseWidget(element.neighbor_mc));
               slotFrame.addWidget(new FarmAnimatedTextButton(element.neighbor_mc.findNeighbor_bt,ZLocUtils.t("Dialogs","AddNeighbor_Button"),function():void
               {
                  FarmStatsManager.count(TrickOrTreatManager.instance.featureCreditName,m_statsSubcounter,"community_neighbors",m_featureCreditName + "_leaderboard","click");
                  ExternalUtil.instance.call("theFarmOverlay.showSuggestionHubOverlay");
               }));
            }
            slotFrame.addWidget(new ZwBaseWidget(element.prize_mc),false);
         }
         else
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(obj.name as String);
            if(farmItem != null)
            {
               slotFrame.addWidget(new ZwBaseWidget(element.neighbor_mc),false);
               slotFrame.addWidget(new FarmAnimatedButton(element.neighbor_mc.findNeighbor_bt),false);
               icon = new FarmIcon(element.prize_mc.prizeIcon_mc,farmItem.icon);
               icon.setIconSize(SLOT_ICON_SIZE,SLOT_ICON_SIZE);
               icon.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(farmItem.friendlyName)));
               slotFrame.addWidget(icon);
               slotFrame.addWidget(new ZwBaseWidget(element.prize_mc.prizehighlight_mc));
               remainingCost = Math.max(0,obj.cost - Global.player.getFeatureCreditsReceived(this.m_featureCreditName));
               if(remainingCost > 0)
               {
                  slotFrame.addWidget(new ZwTextField(element.prize_mc.prizeCost_tf,ZLocUtils.t("Dialogs","trickortreatUnlockPrize",{"count":remainingCost.toString()})));
               }
               else
               {
                  slotFrame.addWidget(new ZwTextField(element.prize_mc.prizeCost_tf,ZLocUtils.t("Dialogs","trickortreatUnlockedPrize")));
               }
            }
         }
         addWidget(slotFrame);
      }
      
      private function onScrollUp(event:Event) : void
      {
         if(Boolean(this.m_friendsContainer) && Boolean(this.m_minScroll > 0) && this.m_enableAnimation)
         {
            FarmStatsManager.sample(100,TrickOrTreatManager.instance.featureCreditName,this.m_statsSubcounter,"leaderboard_scroll");
            this.m_enableAnimation = false;
            this.m_minScroll -= this.m_slotHeight;
            this.m_maxScroll += this.m_slotHeight;
            if(this.m_minScroll <= 0)
            {
               this.m_arrowUp.enabled = false;
            }
            this.m_arrowDown.enabled = true;
            TweenLite.to(this.m_friendsContainer,0.25,{
               "y":this.m_friendsContainer.y + this.m_slotHeight,
               "ease":Quad.easeIn,
               "onComplete":function():void
               {
                  m_enableAnimation = true;
               }
            });
         }
      }
      
      private function onScrollDown(event:Event) : void
      {
         if(Boolean(this.m_friendsContainer) && Boolean(this.m_maxScroll > 0) && this.m_enableAnimation)
         {
            FarmStatsManager.sample(100,TrickOrTreatManager.instance.featureCreditName,this.m_statsSubcounter,"leaderboard_scroll");
            this.m_enableAnimation = false;
            this.m_minScroll += this.m_slotHeight;
            this.m_maxScroll -= this.m_slotHeight;
            if(this.m_maxScroll <= 0)
            {
               this.m_arrowDown.enabled = false;
            }
            this.m_arrowUp.enabled = true;
            TweenLite.to(this.m_friendsContainer,0.25,{
               "y":this.m_friendsContainer.y - this.m_slotHeight,
               "ease":Quad.easeIn,
               "onComplete":function():void
               {
                  m_enableAnimation = true;
               }
            });
         }
      }
      
      private function sortFriendsByStatCount(slot1:Object, slot2:Object) : int
      {
         var result:int = 0;
         var count1:int = 0;
         var count2:int = 0;
         count1 = this.evaluateRank(slot1);
         count2 = this.evaluateRank(slot2);
         if(count1 < count2)
         {
            result = 1;
         }
         else if(count1 > count2)
         {
            result = -1;
         }
         else if(slot1.hasOwnProperty("uid") && slot1.uid == Global.player.uid)
         {
            result = -1;
         }
         else if(slot2.hasOwnProperty("uid") && slot2.uid == Global.player.uid)
         {
            result = 1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      private function evaluateRank(obj:Object) : int
      {
         var count:int = 0;
         if(obj as IUser != null)
         {
            count = (obj as IUser).getFeatureCreditsReceived(this.m_featureCreditName,true);
         }
         else
         {
            count = int(obj.cost);
         }
         return count;
      }
   }
}

