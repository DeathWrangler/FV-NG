package Widgets.Frames
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.GuildManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.GuildConsumableCraftSlot;
   import Widgets.Windows.GuildConsumableCraftWindow;
   import Widgets.Windows.GuildMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class GuildConsumableCraftSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private static const WINDOW_PREFIX:String = "guild_craft_";
      
      private var m_featureName:String = null;
      
      private var m_window:GuildConsumableCraftWindow;
      
      private var m_npcMc:MovieClip;
      
      private var m_npcTalkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_overlayMc:MovieClip;
      
      private var m_tutorialMC:MovieClip;
      
      public function GuildConsumableCraftSlotContainerFrame(element:DisplayObject, featureName:String, window:GuildConsumableCraftWindow)
      {
         var consCount:int = 0;
         var req:int = 0;
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
         if(m_element.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_element["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "title")));
         }
         if(m_element.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorialMC = m_element["tutorial_mc"] as MovieClip;
            this.m_tutorialMC.visible = false;
         }
         if(m_element.hasOwnProperty("body_tf"))
         {
            addWidget(new ZwTextField(m_element["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_PREFIX + "subtitle")));
         }
         if(m_element.hasOwnProperty("npc_mc"))
         {
            this.m_npcMc = m_element.npc_mc as MovieClip;
            this.m_npcMc.visible = false;
            this.m_npcMc.play();
            if(this.m_npcMc.hasOwnProperty("talk_mc"))
            {
               this.m_npcTalkMc = this.m_npcMc.talk_mc as MovieClip;
               this.m_npcTalkMc.visible = true;
               this.m_npc1Tf = new ZwTextField(this.m_npcTalkMc["npc1_tf"]," Auto npc1");
               this.m_npc2Tf = new ZwTextField(this.m_npcTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(GuildMainWindow.m_FTUEState == 6)
         {
            consCount = this.getConsumableCount(GuildManager.getInstance().consumableCodeArray[0]);
            req = int(GuildManager.getInstance().COUNT_ARRAY[0][0]);
            if(consCount >= req)
            {
               this.showNPCCallouts("Crafty Clan!","Click here to craft a token by using the ingredients you have collected.");
            }
         }
         this.refresh();
      }
      
      public function getConsumableCount(consCode:String) : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(consCode));
      }
      
      override protected function setupData() : void
      {
         m_slotData = GuildManager.getInstance().getGuildConsumableCraftData();
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildConsumableCraftSlot(slotElement,this.m_featureName,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "bundle";
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_npcTalkMc.visible = true;
         this.m_npcMc.visible = true;
         this.m_tutorialMC.visible = true;
      }
   }
}

