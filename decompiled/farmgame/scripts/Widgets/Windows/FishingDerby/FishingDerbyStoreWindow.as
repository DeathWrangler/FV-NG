package Widgets.Windows.FishingDerby
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FishingDerby.FishingDerbyStoreFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class FishingDerbyStoreWindow extends FarmWindow
   {
      
      public static const TAB_RODS:String = "TAB_RODS";
      
      public static const TAB_BAITS:String = "TAB_BAITS";
      
      public static const TAB_BUFF:String = "TAB_BUFFS";
      
      public static const FISHING_STORE:String = "fishing_store";
      
      private var m_contentsFrame:FishingDerbyStoreFrame;
      
      private var m_defaultFrame:String;
      
      private var m_emptyText:ZwTextField;
      
      public function FishingDerbyStoreWindow(building:FeatureBuilding, deafultFrame:String = "TAB_BAITS")
      {
         this.m_defaultFrame = deafultFrame;
         var dialogConfig:Object = building.getItem().getDialogConfig("storage");
         super(dialogConfig["path"]);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk("Dialogs","FishingShop_Title")));
         if(m_window.hasOwnProperty("better_tf"))
         {
            addWidget(new ZwTextField(m_window.better_tf,ZLocUtils.t_pk("Dialogs","FishingShopBaitEnhance_Text")));
         }
         var tabsFrame:ZwFrame = new ZwFrame(m_window.mainNav_mc);
         addWidget(tabsFrame);
         addWidget(new FarmAnimatedTextButton(m_window.mainNav_mc.tab_0_bt,"Rods",this.showRods));
         addWidget(new FarmAnimatedTextButton(m_window.mainNav_mc.tab_1_bt,"Baits",this.showBaits));
         addWidget(new FarmAnimatedTextButton(m_window.mainNav_mc.tab_2_bt,"Extras",this.showBuffs));
         if(m_window.hasOwnProperty("empty_tf"))
         {
            addWidget(this.m_emptyText = new ZwTextField(m_window.empty_tf));
         }
         addWidget(this.m_contentsFrame = new FishingDerbyStoreFrame(m_window.slots_mc));
         switch(this.m_defaultFrame)
         {
            case TAB_RODS:
               this.showRods();
               break;
            case TAB_BAITS:
               this.showBaits();
               break;
            case TAB_BUFF:
               this.showBuffs();
               break;
            default:
               this.showBaits();
         }
         StatsManager.count(FeatureOptionsManager.FISHING_DERBY,"bait_shop","impressions");
      }
      
      private function showRods(event:Event = null) : void
      {
         var rodObject:Object = null;
         var rodName:String = null;
         var baitsItems:Array = FishingDerbyManager.instance.getConfigArray(FishingDerbyManager.CONFIG_RODS);
         var rodsRemaining:Array = new Array();
         var fishingInventory:Object = FishingDerbyManager.getFishingInventory();
         for each(rodObject in baitsItems)
         {
            rodName = rodObject["name"];
            if((fishingInventory.unlocked_rods as Array).indexOf(rodName) < 0)
            {
               rodsRemaining.push(rodObject);
            }
         }
         this.m_emptyText.visible = false;
         if(!rodsRemaining.length)
         {
            this.m_emptyText.text = ZLocUtils.t_pk("Dialogs","FishingShop_boughtallitems");
            this.m_emptyText.visible = true;
         }
         this.m_contentsFrame.items = rodsRemaining;
      }
      
      private function showBaits(event:Event = null) : void
      {
         this.m_emptyText.visible = false;
         this.m_contentsFrame.items = FishingDerbyManager.instance.getConfigArray("baitsStore");
      }
      
      private function showBuffs(event:Event = null) : void
      {
         this.m_emptyText.visible = false;
         this.m_contentsFrame.items = FishingDerbyManager.instance.getConfigArray(FishingDerbyManager.CONFIG_BUFFS);
      }
      
      override protected function onClose(event:Event) : void
      {
         Global.world.dispatchEvent(new Event(FISHING_STORE));
         super.onClose(event);
      }
   }
}

