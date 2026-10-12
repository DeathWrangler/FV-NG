package Widgets.Windows.FishingDerby
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FishingDerby.TackleBoxFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   
   public class TackleBoxWindow extends FarmWindow
   {
      
      public static const ASSET_PATH:String = "assets/dialogs/Angler/FV_TackleBox.swf";
      
      public static const TAB_ROD:int = 0;
      
      public static const TAB_BAITS:int = 1;
      
      public static const TAB_EXTRAS:int = 2;
      
      private var m_containerFrame:TackleBoxFrame;
      
      private var m_activeRod:FarmIcon;
      
      private var m_activeBait:FarmIcon;
      
      private var m_activeBuff:FarmIcon;
      
      private var m_tabToOpen:int;
      
      private const FISH_FINDER:String = "fishfinder";
      
      public function TackleBoxWindow(tabToOpen:int = 0)
      {
         this.m_tabToOpen = tabToOpen;
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Title")));
         var activeFrame:ZwFrame = new ZwFrame(m_window.activeItems_mc);
         addWidget(activeFrame);
         activeFrame.addWidget(new ZwTextField(m_window.activeItems_mc.generic_tf,ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Active")));
         activeFrame.addWidget(this.m_activeRod = new FarmIcon(m_window.activeItems_mc.rodIcon_mc));
         this.m_activeRod.setIconSize(50,50);
         activeFrame.addWidget(this.m_activeBait = new FarmIcon(m_window.activeItems_mc.baitIcon_mc));
         this.m_activeBait.setIconSize(50,50);
         activeFrame.addWidget(this.m_activeBuff = new FarmIcon(m_window.activeItems_mc.buffIcon_mc));
         this.m_activeBuff.setIconSize(50,50);
         addWidget(this.m_containerFrame = new TackleBoxFrame(m_window.inventoryItems_mc,this));
         addWidget(new FarmAnimatedTextButton(m_window.generic0_bt,"Rods",this.showRods));
         addWidget(new FarmAnimatedTextButton(m_window.generic1_bt,"Baits",this.showBaits));
         addWidget(new FarmAnimatedTextButton(m_window.generic2_bt,"Extras",this.showBuffs));
         var featureFrame:ZwFrame = new ZwFrame(m_window.featured_mc);
         addWidget(featureFrame);
         featureFrame.addWidget(new ZwTextField(m_window.featured_mc.featuredTitle_tf,ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Featured")));
         featureFrame.addWidget(new FarmAnimatedTextButton(m_window.featured_mc.market_bt,ZLocUtils.t_pk("Dialogs","TackleBoxWindow_BaitShop"),this.openBaitShop));
         switch(this.m_tabToOpen)
         {
            case TAB_ROD:
               this.showRods();
               break;
            case TAB_BAITS:
               this.showBaits();
               break;
            case TAB_EXTRAS:
               this.showBuffs();
               break;
            default:
               this.showRods();
         }
         this.updatePreviewSlots();
         StatsManager.count(FeatureOptionsManager.FISHING_DERBY,"tackle_box","impressions");
      }
      
      private function showRods(event:Event = null) : void
      {
         var itemName:String = null;
         var fishingInventory:Object = FishingDerbyManager.getFishingInventory();
         var unlockedRods:Array = fishingInventory["unlocked_rods"] as Array;
         var items:Array = new Array();
         for each(itemName in unlockedRods)
         {
            items.push({
               "name":itemName,
               "type":"rod"
            });
         }
         this.m_containerFrame.items = items;
      }
      
      private function showBaits(event:Event = null) : void
      {
         var key:String = null;
         var fishingBaits:Object = FishingDerbyManager.getFishingBaits();
         var baitsInventory:Object = fishingBaits["baits"];
         var items:Array = new Array();
         for(key in baitsInventory)
         {
            items.push({
               "name":key,
               "count":baitsInventory[key],
               "type":"bait"
            });
         }
         this.m_containerFrame.items = items;
      }
      
      private function showBuffs(event:Event = null) : void
      {
         var key:String = null;
         var fishingBuffs:Object = FishingDerbyManager.getFishingBuffs();
         var buffsInventory:Object = fishingBuffs["buffs"];
         var items:Array = new Array();
         for(key in buffsInventory)
         {
            items.push({
               "name":key,
               "count":buffsInventory[key],
               "type":"buff"
            });
         }
         this.m_containerFrame.items = items;
      }
      
      private function openBaitShop(event:Event) : void
      {
         close();
         var baitShopArray:Array = Global.world.getObjectsByCode("1lB");
         if(baitShopArray.length > 0)
         {
            UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],FishingDerbyStoreWindow.TAB_BAITS),true,"FishingDerbyStoreWindow",true);
         }
      }
      
      public function updatePreviewSlots() : void
      {
         var fishingInventory:Object = FishingDerbyManager.getFishingInventory();
         var activeRod:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(fishingInventory.rod);
         this.m_activeRod.loadIcon(activeRod.icon);
         var fishingBaits:Object = FishingDerbyManager.getFishingBaits();
         var activeBait:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(fishingBaits.active);
         this.m_activeBait.loadIcon(activeBait.icon);
         var fishingBuffs:Object = FishingDerbyManager.getFishingBuffs();
         this.m_activeBuff.loadIcon(Global.farmGameSettingsManager.getFarmItemByName("fishfinder").icon);
         if(fishingBuffs["active"] == "none" || fishingBuffs["buffs"][fishingBuffs["active"]] <= 0)
         {
            (this.m_activeBuff.element as MovieClip).filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         this.m_containerFrame.refresh();
      }
   }
}

