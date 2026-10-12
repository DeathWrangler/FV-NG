package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ToasterIconPaths;
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.SuperPlotManager;
   import Managers.ToasterManager;
   import Widgets.Windows.AutoCloseToasterWindow;
   import Widgets.Windows.ConsumablePurchaseToasterWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   
   public class TBuyConsumables extends TFarmTransaction
   {
      
      protected var m_item:FarmItem;
      
      protected var m_onBuyCallback:Function;
      
      private var m_displayBuyMessage:Boolean = true;
      
      private var m_onPurchaseCompleteCallBack:Function;
      
      public function TBuyConsumables(item:String, isGift:Boolean = false, extraData:Object = null, onBuyCallback:Function = null, onPurchaseCompleteCallBack:Function = null)
      {
         super();
         if(extraData != null && extraData.displayBuyMessage != null)
         {
            this.m_displayBuyMessage = extraData.displayBuyMessage;
         }
         this.m_onBuyCallback = onBuyCallback;
         this.m_onPurchaseCompleteCallBack = onPurchaseCompleteCallBack;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(item);
         Global.player.addGift(item);
         if(Global.player.canBuyItem(null,false,this.m_item))
         {
            Global.player.tryBuy(null,false,this.m_item);
         }
         this.onBuyConsumables();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(this.m_item.rewardsData != null)
            {
               UserRewardUtil.grantUserRewardsFromDataSource(this.m_item.rewardsData);
            }
         }
         else if(this.m_item.hasOwnProperty("rewardsXML") && this.m_item.rewardsXML != null)
         {
            UserRewardUtil.grantUserRewardsFromXml(this.m_item.rewardsXML);
         }
      }
      
      override public function perform() : void
      {
         var itemName:String = null;
         var packagedItem:ConsumableItem = null;
         var count:int = 0;
         signedCall("FarmService.buyConsumablePackage",this.m_item.name);
         var packagedItems:Object = this.m_item.getItemPackageHash();
         for(itemName in packagedItems)
         {
            packagedItem = Global.farmGameSettingsManager.getFarmItemByName(itemName) as ConsumableItem;
            if(packagedItem)
            {
               if(packagedItem.useOnBuy())
               {
                  if(!packagedItem.isAutoConsumable())
                  {
                     for(count = 0; count < packagedItems[itemName]; count++)
                     {
                        packagedItem.onUse();
                     }
                  }
               }
               if(packagedItem.name == SuperPlotManager.CONSUMABLE_ITEM_NAME)
               {
                  SuperPlotManager.conditionallyShowMOTD();
               }
            }
         }
      }
      
      protected function onBuyConsumables() : void
      {
         var titleMsg:String = null;
         var msg:String = null;
         var onBuyToaster:AutoCloseToasterWindow = null;
         if(this.m_onBuyCallback != null)
         {
            this.m_onBuyCallback();
         }
         else if(this.m_displayBuyMessage)
         {
            titleMsg = ZLocUtils.t("Dialogs","ConsumablesBought_Title");
            msg = ZLocUtils.t("Dialogs","ConsumablesBought",{"item":ZLocUtils.tk_pk(this.m_item.friendlyName)});
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
            {
               onBuyToaster = new ConsumablePurchaseToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMABLE_PURCHASE);
               onBuyToaster.isPauseable = false;
            }
            else
            {
               onBuyToaster = new TwoIconTitleToasterWindow(titleMsg,msg,this.m_item.icon,ToasterIconPaths.GIFT_ICON,ToasterIconPaths.DIALOG_ASSET,0.6,0.7,new Point(8,8),new Point(7,0),null);
            }
            ToasterManager.getInstance().add(onBuyToaster);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_onPurchaseCompleteCallBack != null)
         {
            this.m_onPurchaseCompleteCallBack();
         }
      }
   }
}

