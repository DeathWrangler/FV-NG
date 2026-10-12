package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.ManagedSale;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Managers.ExperimentManager;
   import Managers.ManagedSalesManager;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class UltimateStarterPackMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_itemName:String;
      
      public function UltimateStarterPackMOTD(displayParams:Object = null)
      {
         super(displayParams);
         this.m_itemName = displayParams["item"];
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var salePrice:int = 0;
         var saleObj:ManagedSale = null;
         super.onLoadComplete(event);
         var expManager:ExperimentManager = new ExperimentManager();
         var variant:Number = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_XTL_ULTIMATE_STARTER);
         var pkg_item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName + (variant - 1).toString());
         if(this.isVisibleToUser(pkg_item) == false)
         {
            onClose(null);
            return;
         }
         if(ObjectUtil.pathExists(m_window,["mainWindow","subtitle_tf"]))
         {
            addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ultimatestarterpackSubTitle")),true);
         }
         if(ObjectUtil.pathExists(m_window,["mainWindow","accept_bt","generic_tf"]))
         {
            addWidget(new FarmTextField(m_window.mainWindow.accept_bt.generic_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ultimatestarterpackAccept")),true);
         }
         if(ObjectUtil.pathExists(m_window,["mainWindow","price_mc","oldprice_tf"]))
         {
            if(pkg_item)
            {
               addWidget(new FarmTextField(m_window.mainWindow.price_mc.oldprice_tf,pkg_item.cash.toString()));
            }
         }
         if(ObjectUtil.pathExists(m_window,["mainWindow","price_mc","newprice_tf"]))
         {
            if(pkg_item)
            {
               salePrice = pkg_item.cash;
               saleObj = ManagedSalesManager.getSaleObject(pkg_item);
               if(saleObj)
               {
                  salePrice = saleObj.price;
               }
            }
            addWidget(new FarmTextField(m_window.mainWindow.price_mc.newprice_tf,salePrice.toString()));
         }
         if(ObjectUtil.pathExists(m_window,["mainWindow","animation_mc"]))
         {
            MovieClip(m_window.mainWindow.animation_mc).gotoAndPlay(1);
         }
      }
      
      private function isVisibleToUser(pkg_item:FarmItem) : Boolean
      {
         var sizeX:int = Global.world.getGridWidth();
         var sizeY:int = Global.world.getGridHeight();
         if(pkg_item["squares"] > sizeX && pkg_item["squares"] > sizeY)
         {
            return true;
         }
         return false;
      }
   }
}

