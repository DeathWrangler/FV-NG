package Widgets.Windows.Quests
{
   import Classes.Avatar.AvatarItem;
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   
   public class NoShareQuestChainCompleteWindow extends WindowWithRewardItem
   {
      
      private static const ASSET_KEY_POSTFIX:String = "_shareWindow";
      
      private var m_farmQuest:FarmQuest = null;
      
      public function NoShareQuestChainCompleteWindow(farmQuest:FarmQuest)
      {
         var assetUrl:String = Global.farmGameSettingsManager.getAttribute(farmQuest.chain + ASSET_KEY_POSTFIX);
         super(assetUrl);
         this.m_farmQuest = farmQuest;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var generic4:String = "";
         var generic6:String = "";
         var timeTillNext:String = this.timeTillNextQuest();
         if(timeTillNext != "")
         {
            generic4 = ZLocUtils.t("Quests",this.m_farmQuest.textBundle + "_Generic4");
            generic6 = ZLocUtils.t("Quests",this.m_farmQuest.textBundle + "_Generic6");
            if(m_window.counterbg_mc)
            {
               addWidget(new ZwFrame(m_window.counterbg_mc));
            }
         }
         if(m_window.generic4_tf)
         {
            addWidget(new ZwTextField(m_window.generic4_tf,generic4));
         }
         else if(m_window.mainWindow.generic4_tf)
         {
            addWidget(new ZwTextField(m_window.mainWindow.generic4_tf,generic4));
         }
         if(m_window.generic5_tf)
         {
            addWidget(new ZwTextField(m_window.generic5_tf,timeTillNext));
         }
         else if(m_window.mainWindow.generic5_tf)
         {
            addWidget(new ZwTextField(m_window.mainWindow.generic5_tf,timeTillNext));
         }
         if(m_window.generic6_tf)
         {
            addWidget(new ZwTextField(m_window.generic6_tf,generic6));
         }
         else if(m_window.mainWindow.generic6_tf)
         {
            addWidget(new ZwTextField(m_window.mainWindow.generic6_tf,generic6));
         }
      }
      
      override protected function getTitle() : String
      {
         return this.m_farmQuest.titleText;
      }
      
      override protected function getRewardText() : String
      {
         var reward:Object = null;
         var rewardName:String = null;
         var result:String = "";
         if(this.m_farmQuest.farmRewards.length > 0)
         {
            var _loc4_:int = 0;
            var _loc5_:* = this.m_farmQuest.farmRewards;
            for each(reward in _loc5_)
            {
               rewardName = ZLocUtils.tk_pk_asTitle("Items:" + Global.farmGameSettingsManager.getFarmItemNameByCode(reward.value) + "_friendlyName");
               result = ZLocUtils.t("Quests",this.m_farmQuest.textBundle + "_Reward",{"rewardName":rewardName});
            }
         }
         return result;
      }
      
      override protected function getRewardShareButtonText() : String
      {
         return ZLocUtils.t("Quests",this.m_farmQuest.textBundle + "_RewardBody");
      }
      
      override protected function getRewardButtonText() : String
      {
         return this.m_farmQuest.rewardShareButtonText;
      }
      
      override protected function getExtraRewardText() : String
      {
         return this.m_farmQuest.extraRewardText;
      }
      
      private function timeTillNextQuest() : String
      {
         var secondsLeft:Number = NaN;
         var daysLeft:String = "";
         var childQuest:FarmQuest = FarmQuestManager.getInstance().getFirstChildQuest(this.m_farmQuest);
         if(childQuest)
         {
            secondsLeft = (childQuest.startTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            daysLeft = FarmGameUtil.parseTimeLeft(secondsLeft)[0].toString();
         }
         return daysLeft;
      }
      
      override protected function showRewardItem(farmItem:FarmItem) : void
      {
         var icon:FarmIcon = null;
         var itemPreview:ObjectPreviewFrame = null;
         var reward:Object = null;
         var avatarItem:AvatarItem = null;
         farmItem = null;
         var index:int = 0;
         var icon_mc:String = "icon_mc";
         var icon_tf:String = "icon_tf";
         if(this.m_farmQuest.farmRewards.length > 0)
         {
            for each(reward in this.m_farmQuest.farmRewards)
            {
               if(this.m_farmQuest.farmRewards.length > 1)
               {
                  icon_mc = "icon_" + index + "_mc";
                  icon_tf = "icon_" + index + "_tf";
               }
               if(m_window[icon_mc])
               {
                  if(reward.type == QuestConstants.REWARD_GRANT_ITEM)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                     if(this.m_farmQuest.farmRewards.length == 1 && !(farmItem is ConsumableItem))
                     {
                        itemPreview = new ObjectPreviewFrame(m_window[icon_mc],farmItem,null,null,[PREVIEWWIDTH]);
                        itemPreview.y += PREVIEWWIDTH / 2;
                        addWidget(itemPreview);
                     }
                     else
                     {
                        addWidget(new FarmIcon(m_window[icon_mc],farmItem.icon));
                     }
                     if(m_window[icon_tf])
                     {
                        addWidget(new ZwTextField(m_window[icon_tf],farmItem.friendlyTitle));
                     }
                  }
                  else if(reward.type == QuestConstants.REWARD_AVATAR_ITEM)
                  {
                     icon = new FarmIcon(m_window[icon_mc],this.m_farmQuest.getImageForRewardAtIndex(index));
                     addWidget(icon);
                     if(Boolean(m_window[icon_tf]) && Boolean(reward.value))
                     {
                        avatarItem = Global.avatarConfigSettings.getItemById(reward.value);
                        if(avatarItem)
                        {
                           addWidget(new ZwTextField(m_window[icon_tf],ZLocUtils.tk_pk_asTitle(avatarItem.friendlyName)));
                        }
                     }
                  }
                  else
                  {
                     icon = new FarmIcon(m_window[icon_mc],this.m_farmQuest.getImageForRewardAtIndex(index));
                     addWidget(icon);
                     if(Boolean(m_window[icon_tf]) && Boolean(reward.value))
                     {
                        addWidget(new ZwTextField(m_window[icon_tf],"x" + reward.value));
                     }
                  }
               }
               index++;
            }
         }
      }
   }
}

