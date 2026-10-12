package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Managers.MystreeReskinManager;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class NutcrackerTheater extends FeatureBuilding
   {
      
      private var m_storageContents:Dictionary = new Dictionary();
      
      public function NutcrackerTheater(itemName:String)
      {
         super(itemName);
      }
      
      override public function showMenu() : void
      {
         var item:FarmItem = null;
         var featureName:String = null;
         m_menuItems = [];
         if(this.state == STATE_BUSY || !Global.worldManager.isWorldSwapStable)
         {
            showObjectBusy();
         }
         else
         {
            item = getItem();
            if(item)
            {
               featureName = item.featureName;
               if(MystreeReskinManager.getInstance(featureName))
               {
                  if(MystreeReskinManager.getInstance(featureName).isFeatureAvailable())
                  {
                     m_menuItems.push({
                        "label":ZLocUtils.t("FarmGame","LookInside"),
                        "action":LOOK_INSIDE
                     });
                  }
               }
            }
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
            UI.displayMenu(m_menuItems,this.onMenuClick);
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case LOOK_INSIDE:
                  this.openMystreeUI();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function openMystreeUI() : void
      {
         var featureName:String = null;
         var item:FarmItem = getItem();
         if(item)
         {
            featureName = item.featureName;
            MystreeReskinManager.getInstance(featureName).openMystreeUI();
         }
      }
   }
}

