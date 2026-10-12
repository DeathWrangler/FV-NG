package Widgets.Frames.CreditsBuilding
{
   import Classes.IUser;
   import Classes.RewardCreditsBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.CreditsBuilding.LeaderBoardSlot;
   import flash.display.DisplayObject;
   
   public class LeaderBoardFrame extends FarmSlotContainerFrame
   {
      
      protected static const PROPERTIES_FILE_NAME:String = "Dialogs";
      
      protected static const USER_ICON_SIZE:Number = 56;
      
      protected static const USER_ICON_OFFSET_X:Number = 1.5;
      
      protected static const USER_ICON_OFFSET_Y:Number = 2;
      
      protected var m_building:RewardCreditsBuilding = null;
      
      protected var m_featureName:String;
      
      protected var m_friends:Array = new Array();
      
      protected var m_levelTitles:Array = new Array();
      
      public function LeaderBoardFrame(element:DisplayObject, building:RewardCreditsBuilding, featureName:String)
      {
         this.m_building = building;
         this.m_featureName = featureName;
         this.populateFriendsList();
         this.populateLevelTitles();
         super(element);
         var pageBackArrow:ZwButton = new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack);
         addWidget(pageBackArrow);
         m_pageBackWidget = pageBackArrow;
         var pageForwardArrow:ZwButton = new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward);
         addWidget(pageForwardArrow);
         m_pageForwardWidget = pageForwardArrow;
         var frame:ZwFrame = new ZwFrame(m_element.playerPanel_mc);
         this.buildPlayerPanelFrame(frame);
         addWidget(frame);
         refresh();
      }
      
      public function repopulateData() : void
      {
         this.setupData();
         this.populatePlayerPanel();
         refresh();
      }
      
      override protected function setupData() : void
      {
         var friend:IUser = null;
         var friendData:Object = null;
         var friendPlayer:IUser = null;
         m_slotData = new Array();
         this.m_friends.sort(this.sortFriendsByCreditsReceived);
         for(var index:int = 0; index < this.m_friends.length; index++)
         {
            friend = this.m_friends[index];
            if(friend)
            {
               friendData = new Object();
               friendData.rank = index + 1;
               friendData.name = "";
               if(friend.uid == Global.player.snUser.uid)
               {
                  friendData.name = Global.player.snUser.name;
               }
               else
               {
                  friendPlayer = Global.friendManager.getFriendData(friend.uid);
                  if(friendPlayer)
                  {
                     friendData.name = friendPlayer.name;
                  }
               }
               friendData.creditsReceived = friend.getFeatureCreditsReceived(this.m_featureName);
               friendData.title = this.getLevelTitle(friendData.creditsReceived);
               if(friendData.title)
               {
                  friendData.title = this.quoteTitle(friendData.title);
               }
               friendData.uid = friend.uid;
               m_slotData.push(friendData);
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LeaderBoardSlot(slotElement,this.m_featureName);
      }
      
      protected function populateFriendsList() : void
      {
         this.m_friends = Global.friendManager.neighbors.concat();
         this.m_friends.push(Global.player);
         this.m_friends.sort(this.sortFriendsByCreditsReceived);
      }
      
      protected function sortFriendsByCreditsReceived(friend1:IUser, friend2:IUser) : int
      {
         var result:int = 0;
         var credits1:int = friend1.getFeatureCreditsReceived(this.m_featureName);
         var credits2:int = friend2.getFeatureCreditsReceived(this.m_featureName);
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
      
      protected function buildPlayerPanelFrame(frame:ZwFrame) : void
      {
         var friend:IUser = null;
         var element:Object = frame.element;
         var playerRank:uint = 0;
         for(var index:uint = 0; index < this.m_friends.length; index++)
         {
            friend = this.m_friends[index];
            if(friend.uid == Global.player.snUser.uid)
            {
               playerRank = index + 1;
               break;
            }
         }
         var credits:uint = this.m_building.getTotalCreditsReceived();
         frame.addWidget(new ZwTextField(element.name_tf,Global.player.snUser.name));
         var rankingStr:String = "";
         var rankingPK:String = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"Ranking");
         if("" == rankingPK)
         {
            rankingPK = "RewardCreditsBuilding:Ranking";
         }
         rankingStr = ZLocUtils.t_pk(rankingPK,null,{
            "rank":playerRank,
            "total":this.m_friends.length
         });
         frame.addWidget(new ZwTextField(element.rank_tf,rankingStr));
         frame.addWidget(new ZwTextField(element.title_tf,this.quoteTitle(this.getLevelTitle(credits))));
         frame.addWidget(new ZwTextField(element.points_tf,ZLocUtils.t("Dialogs","RewardCredits_Score",{
            "quantity":credits,
            "creditName":ZLocUtils.tk_pk(RewardCreditsBuilding.getCreditItemFriendlyName(this.m_featureName),"",credits)
         })));
         var iconURL:String = FarmGameUtil.getFriendIconByUid(Global.player.snUser.uid);
         var userIcon:FarmIcon = new FarmIcon(element.icon,iconURL);
         userIcon.setIconSize(USER_ICON_SIZE,USER_ICON_SIZE);
         userIcon.x += USER_ICON_OFFSET_X;
         userIcon.y += USER_ICON_OFFSET_Y;
         addWidget(userIcon);
      }
      
      public function populatePlayerPanel() : void
      {
         var playerRank:uint = 0;
         var index:uint = 0;
         var credits:uint = 0;
         var rankTextField:ZwTextField = null;
         var rankingStr:String = null;
         var rankingPK:String = null;
         var titleTextField:ZwTextField = null;
         var pointsTextField:ZwTextField = null;
         var friend:IUser = null;
         var playerFrame:ZwFrame = getWidget(m_element.playerPanel_mc) as ZwFrame;
         if(playerFrame)
         {
            playerRank = 0;
            for(index = 0; index < this.m_friends.length; index++)
            {
               friend = this.m_friends[index];
               if(friend.uid == Global.player.snUser.uid)
               {
                  playerRank = index + 1;
                  break;
               }
            }
            credits = this.m_building.getTotalCreditsReceived();
            rankTextField = playerFrame.getWidget(playerFrame.element.rank_tf) as ZwTextField;
            rankingStr = "";
            rankingPK = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"Ranking");
            if("" == rankingPK)
            {
               rankingPK = "RewardCreditsBuilding:Ranking";
            }
            rankingStr = ZLocUtils.t_pk(rankingPK,null,{
               "rank":playerRank,
               "total":this.m_friends.length
            });
            rankTextField.text = rankingStr;
            titleTextField = playerFrame.getWidget(playerFrame.element.title_tf) as ZwTextField;
            titleTextField.text = this.quoteTitle(this.getLevelTitle(credits));
            pointsTextField = playerFrame.getWidget(playerFrame.element.points_tf) as ZwTextField;
            pointsTextField.text = ZLocUtils.t("Dialogs","RewardCredits_Score",{
               "quantity":credits,
               "creditName":ZLocUtils.tk_pk(RewardCreditsBuilding.getCreditItemFriendlyName(this.m_featureName),"",credits)
            });
         }
      }
      
      protected function populateLevelTitles() : void
      {
         var str:String = null;
         var strPK:String = null;
         var levels:Array = this.m_building.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            str = "";
            strPK = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"Level_" + (index + 1));
            if("" != strPK)
            {
               str = ZLocUtils.t_pk(strPK);
            }
            this.m_levelTitles[index] = str;
         }
      }
      
      protected function getLevelTitle(numCreditsReceived:uint) : String
      {
         var titlePK:String = null;
         var title:String = "";
         var levels:Array = this.m_building.getLevelCredits();
         for(var index:uint = 0; index < levels.length; index++)
         {
            if(numCreditsReceived >= levels[index])
            {
               title = this.m_levelTitles[index];
            }
         }
         if(!title)
         {
            titlePK = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"Level_0");
            if("" != titlePK)
            {
               title = ZLocUtils.t_pk(titlePK);
            }
         }
         return title;
      }
      
      protected function quoteTitle(title:String) : String
      {
         return "\"" + title + "\"";
      }
   }
}

