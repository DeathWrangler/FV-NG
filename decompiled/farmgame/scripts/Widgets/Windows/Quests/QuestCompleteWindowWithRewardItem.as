package Widgets.Windows.Quests
{
   import Classes.Avatar.AvatarItem;
   import Classes.Constants.QuestConstants;
   import Classes.ImageLoader;
   import Classes.Quest.FarmQuest;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.Quests.TShareQuestLoot;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Interfaces.IQuestRewardView;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class QuestCompleteWindowWithRewardItem extends WindowWithRewardItem implements IQuestRewardView
   {
      
      private static const DEFAULT_ASSET_URL:String = "assets/dialogs/FV_PenguinEscapade_share.swf";
      
      private static const ASSET_KEY_POSTFIX:String = "_shareWindow";
      
      private static const ASSET_KEY_BG_POSTFIX:String = "_shareWindowBackground";
      
      protected var m_farmQuest:FarmQuest = null;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      public function QuestCompleteWindowWithRewardItem(farmQuest:FarmQuest)
      {
         var assetUrl:String = Global.farmGameSettingsManager.getAttribute(farmQuest.name + ASSET_KEY_POSTFIX);
         if(assetUrl == null)
         {
            assetUrl = Global.farmGameSettingsManager.getAttribute(farmQuest.chain + ASSET_KEY_POSTFIX,DEFAULT_ASSET_URL);
         }
         super(assetUrl);
         this.m_farmQuest = farmQuest;
         var dialogBackground:String = Global.farmGameSettingsManager.getAttribute(farmQuest.name + ASSET_KEY_BG_POSTFIX);
         if(dialogBackground == null)
         {
            dialogBackground = Global.farmGameSettingsManager.getAttribute(farmQuest.chain + ASSET_KEY_BG_POSTFIX);
         }
         this.m_dialogBackground = dialogBackground;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function getTitle() : String
      {
         return this.m_farmQuest.titleText;
      }
      
      override protected function getRewardText() : String
      {
         return this.m_farmQuest.rewardText;
      }
      
      override protected function getRewardShareButtonText() : String
      {
         return this.m_farmQuest.rewardShareButtonText;
      }
      
      override protected function getExtraRewardText() : String
      {
         return this.m_farmQuest.extraRewardText;
      }
      
      override public function show() : void
      {
         super.show();
         FarmStatsManager.count("fv_quest",this.m_farmQuest.name,"reward","impression");
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
      
      public function postRewardFeed(rewardLink:String) : void
      {
         var creativeBundleName:String = null;
         var item:FarmItem = null;
         var bundleData:Object = null;
         if(rewardLink != null)
         {
            creativeBundleName = this.m_farmQuest.creativeBundleName;
            item = this.m_farmQuest.friendRewardItem;
            if(creativeBundleName != null && creativeBundleName != "" && item != null)
            {
               bundleData = {
                  "actor":Global.player.firstName,
                  "reward_link":rewardLink,
                  "item_name":item.friendlyName,
                  "images":[{
                     "src":Global.getAssetURL(this.m_farmQuest.completeShareFeedIcon),
                     "href":Config.SN_APP_URL + rewardLink
                  }]
               };
               FarmStatsManager.count("fv_quest",this.m_farmQuest.name,"reward","feed_click");
               GlobalEngine.socialNetwork.publishFeedStory(creativeBundleName,bundleData,[],false);
            }
         }
         close();
      }
      
      override protected function onShareClick(event:MouseEvent) : void
      {
         TransactionManager.addTransaction(new TShareQuestLoot(this.m_farmQuest.name,true,this),true);
         super.onShareClick(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         TransactionManager.addTransaction(new TShareQuestLoot(this.m_farmQuest.name,false,this),true);
         super.onClose(event);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window.loader_mc) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.loader_mc));
         }
      }
   }
}

