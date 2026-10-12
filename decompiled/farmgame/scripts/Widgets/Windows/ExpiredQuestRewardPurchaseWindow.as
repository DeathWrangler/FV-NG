package Widgets.Windows
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Display.GenericPopup;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Widgets.Icons.FarmIcon;
   
   public class ExpiredQuestRewardPurchaseWindow extends ExpiredRewardWindow
   {
      
      public static const QUEST_RECAPTURE_STATS_COUNTER:String = "Quest_recap";
      
      private static const MISSING_HUD_ICON:String = "none";
      
      private const SLOT_ASSET_PATH_3:String = "assets/dialogs/FV_questPurchase.swf";
      
      private const SLOT_ASSET_PATH_8:String = "assets/dialogs/FV_questPurchaseAll.swf";
      
      private var m_items:Array;
      
      private var m_quest:FarmQuest;
      
      public function ExpiredQuestRewardPurchaseWindow(quest:FarmQuest, data:Array)
      {
         this.m_quest = quest;
         var assetPath:String = this.SLOT_ASSET_PATH_3;
         this.m_items = data;
         if(this.m_items.length > 3)
         {
            assetPath = this.SLOT_ASSET_PATH_8;
         }
         var questText:String = this.getQuestText() + " quest";
         super(assetPath,questText,data,QUEST_RECAPTURE_STATS_COUNTER);
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         super.postLoadComplete();
         if(m_window["npc_mc"])
         {
            iconUrl = this.getQuestIcon();
            if(iconUrl != MISSING_HUD_ICON)
            {
               addWidget(new FarmIcon(m_window["npc_mc"],iconUrl));
            }
         }
         Global.player.setSeenSessionFlag("questRecaptureFlow");
      }
      
      override protected function onShow() : void
      {
         StatsManager.count(QUEST_RECAPTURE_STATS_COUNTER,this.m_quest.chain,"impressions",this.m_items.length.toString(),this.m_quest.chapter.toString() + "," + this.m_quest.questNumber.toString());
         super.onShow();
      }
      
      override protected function onConfirmBuyAll(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            if(Global.player.canBuyCash(m_totalPrice))
            {
               StatsManager.count(QUEST_RECAPTURE_STATS_COUNTER,this.m_quest.chain,"Buy all",m_totalPrice.toString(),this.m_quest.chapter.toString() + "-" + this.m_quest.questNumber.toString());
            }
         }
         super.onConfirmBuyAll(event);
      }
      
      private function getQuestText() : String
      {
         var questName:String = null;
         var text:String = FarmQuestManager.getInstance().getQuestChainFriendlyName(this.m_quest.name);
         var quest:FarmQuest = this.m_quest;
         while(text == "")
         {
            if(quest.children.length <= 0)
            {
               break;
            }
            questName = quest.children[0]["value"];
            text = FarmQuestManager.getInstance().getQuestChainFriendlyName(questName);
            quest = FarmQuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
         }
         return text;
      }
      
      private function getQuestIcon() : String
      {
         var questName:String = null;
         var iconUrl:String = this.m_quest.icon;
         var quest:FarmQuest = this.m_quest;
         while(iconUrl == MISSING_HUD_ICON)
         {
            if(quest.children.length <= 0)
            {
               break;
            }
            questName = quest.children[0]["value"];
            quest = FarmQuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
            iconUrl = quest.icon;
         }
         return iconUrl;
      }
      
      public function get quest() : FarmQuest
      {
         return this.m_quest;
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}

