package Widgets.Windows.Quests
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Classes.TimerUtil;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.events.Event;
   
   public class ContextMenuQuestRewardWindow extends FarmWindow
   {
      
      private const DEFAULT_ASSET_PATH:String = "assets/dialogs/fv_contextQuest_Orchard.swf";
      
      private const MAX_MSECS_LOOKING_FOR_QUEST:int = 15000;
      
      private var m_quest:FarmQuest;
      
      public function ContextMenuQuestRewardWindow(quest:FarmQuest)
      {
         var windowAssetPath:String = Global.farmGameSettingsManager.getString("ContextMenuQuestRewardWindowUrl_" + quest.chain);
         if(!windowAssetPath)
         {
            windowAssetPath = this.DEFAULT_ASSET_PATH;
         }
         super(windowAssetPath);
         this.m_quest = quest;
      }
      
      override protected function postLoadComplete() : void
      {
         var prizeFrame:ZwFrame = null;
         var reward:Object = null;
         var icon:FarmIcon = null;
         var item:FarmItem = null;
         var iconTooltipText:String = null;
         var findTextKey:String = null;
         super.postLoadComplete();
         addWidget(new FarmTextField(m_window.title_tf,this.m_quest.titleText));
         var rewardFrame:ZwFrame = addWidget(new ZwFrame(m_window.reward_mc)) as ZwFrame;
         rewardFrame.addWidget(new FarmIcon(rewardFrame.element.npcIcon_mc,this.m_quest.avatarHeadImage));
         rewardFrame.addWidget(new FarmTextField(rewardFrame.element.npcText_tf,this.m_quest.rewardText));
         var rewardCount:int = int(this.m_quest.farmRewards.length);
         var index:int = 0;
         while(index <= rewardCount && rewardFrame.element["prize" + (index + 1) + "_mc"] != null)
         {
            reward = this.m_quest.farmRewards[index];
            prizeFrame = rewardFrame.addWidget(new ZwFrame(rewardFrame.element["prize" + (index + 1) + "_mc"])) as ZwFrame;
            if(prizeFrame.element.icon_mc)
            {
               icon = prizeFrame.addWidget(new FarmIcon(prizeFrame.element.icon_mc,UserRewardUtil.getImageForReward(reward))) as FarmIcon;
               iconTooltipText = "";
               switch(reward.type)
               {
                  case QuestConstants.REWARD_GRANT_ITEM:
                     item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                     if(item)
                     {
                        iconTooltipText = item.friendlyTitle;
                     }
                     break;
                  case QuestConstants.REWARD_LICENSE:
                     item = Global.farmGameSettingsManager.getFarmItemByCode(reward.item);
                     if(item)
                     {
                        iconTooltipText = ZLocUtils.t("Dialogs","ContextMenuQuestReward_IconTooltip_license",{"item":item.friendlyTitle});
                     }
               }
               if(iconTooltipText)
               {
                  icon.attachTooltip(new FarmTextTooltip(iconTooltipText));
               }
            }
            if(prizeFrame.element.amount_tf)
            {
               prizeFrame.addWidget(new FarmTextField(prizeFrame.element.amount_tf,UserRewardUtil.getValueForReward(reward)));
            }
            if(prizeFrame.element.find_tf)
            {
               findTextKey = "ContextMenuQuestReward_" + this.m_quest.chain + "_WhereToFind_" + reward.type;
               if(ZLocUtils.hasString("Dialogs",findTextKey))
               {
                  prizeFrame.addWidget(new FarmTextField(prizeFrame.element.find_tf,ZLocUtils.t("Dialogs",findTextKey)));
               }
            }
            index++;
         }
         var continueText:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs","ContextMenuQuestReward_" + this.m_quest.name + "_continue"),new ZLocFailoverEntry("Dialogs","Continue")]);
         var okayBt:FarmAnimatedTextButton = new FarmAnimatedTextButton(rewardFrame.element.okay_bt,continueText);
         okayBt.callback = this.generateOnClickContinue(okayBt,this);
         rewardFrame.addWidget(okayBt);
      }
      
      private function generateOnClickContinue(widget:ZwWidget, window:FarmWindow) : Function
      {
         return function(e:Event):void
         {
            var reward:* = undefined;
            var questToOpen:* = undefined;
            var quest:* = undefined;
            var licenseItemName:* = undefined;
            var onQuestUpdatesFunc:* = undefined;
            widget.enabled = false;
            var licenseItemNames:* = [];
            for each(reward in m_quest.farmRewards)
            {
               if(reward.type == QuestConstants.REWARD_LICENSE)
               {
                  licenseItemName = Global.farmGameSettingsManager.getFarmItemNameByCode(reward.item);
                  if(licenseItemName)
                  {
                     licenseItemNames.push(licenseItemName);
                  }
               }
            }
            if(licenseItemNames.length > 0)
            {
               UI.displayMiniMarketDialog(licenseItemNames);
            }
            var questChainName:* = m_quest.chain;
            for each(quest in FarmQuestManager.getInstance().getActiveQuests())
            {
               if(questChainName == quest.chain && !FarmQuestManager.getInstance().isQuestComplete(quest.name))
               {
                  questToOpen = quest;
                  break;
               }
            }
            if(questToOpen == null)
            {
               onQuestUpdatesFunc = generateOnQuestUpdates(m_quest.chain);
               QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,onQuestUpdatesFunc);
               TimerUtil.callLater(generateRemoveQuestListener(onQuestUpdatesFunc),MAX_MSECS_LOOKING_FOR_QUEST);
            }
            else
            {
               questToOpen.showProgress();
            }
            window.close();
         };
      }
      
      private function generateOnQuestUpdates(chainToFind:String) : Function
      {
         return function(e:QuestEvent):void
         {
            var farmQuest:* = e.quest as FarmQuest;
            if(farmQuest)
            {
               if(farmQuest.chain == chainToFind && !FarmQuestManager.getInstance().isQuestComplete(farmQuest.name))
               {
                  QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,arguments.callee);
                  farmQuest.showProgress();
               }
            }
         };
      }
      
      private function generateRemoveQuestListener(func:Function) : Function
      {
         return function():void
         {
            if(func != null)
            {
               QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,func);
            }
         };
      }
   }
}

