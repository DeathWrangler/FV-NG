package Transactions
{
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Display.InventoryWithdrawal;
   
   public class TUpgradeStorage extends TWorldState
   {
      
      public static const ACTION_UPGRADE_STORAGE:String = "upgradeStorage";
      
      public static const ACTION_PURCHASE_UPGRADE_STORAGE:String = "purchaseStorageUpgrade";
      
      public static const ACTION_CANCEL_UPGRADE_STORAGE:String = "cancelStorageUpgrade";
      
      public static const ACTION_GET_STORAGE_INFO:String = "getStorageInfo";
      
      public static const TYPE_UPGRADE:String = "upgrade";
      
      public static const TYPE_PURCHASE:String = "purchase";
      
      public static const TYPE_CANCEL:String = "cancel";
      
      public static const TYPE_COMPLETE:String = "complete";
      
      public static const TYPE_UPDATE:String = "update";
      
      protected var m_building:StorageBuilding;
      
      protected var m_params:Object;
      
      protected var m_callback:Function = null;
      
      protected var m_storageDialog:InventoryWithdrawal;
      
      protected var m_actionName:String;
      
      protected var m_type:String;
      
      protected var m_discount:int;
      
      public function TUpgradeStorage(building:StorageBuilding, window:InventoryWithdrawal, type:String = "update", callback:Function = null)
      {
         var itemPurchased:FarmItem = null;
         var cashPurchaseAmount:int = 0;
         this.m_params = {};
         super(building);
         this.m_building = building;
         this.m_storageDialog = window;
         this.m_type = type;
         this.m_callback = callback;
         this.m_discount = 0;
         switch(this.m_type)
         {
            case TUpgradeStorage.TYPE_UPGRADE:
               this.m_actionName = TUpgradeStorage.ACTION_UPGRADE_STORAGE;
               break;
            case TUpgradeStorage.TYPE_PURCHASE:
               itemPurchased = Global.farmGameSettingsManager.getFarmItemByName(this.m_building.getItem().getExpansion());
               cashPurchaseAmount = itemPurchased.cash - int(Global.player.upgradeStatus.numHelped);
               if(Global.player.canBuyCash(cashPurchaseAmount,true))
               {
                  this.m_actionName = TUpgradeStorage.ACTION_PURCHASE_UPGRADE_STORAGE;
               }
               else if(this.m_storageDialog)
               {
                  canPerform = false;
                  this.m_storageDialog.refreshLayout(true);
               }
               else
               {
                  canPerform = false;
               }
               break;
            case TUpgradeStorage.TYPE_CANCEL:
            case TUpgradeStorage.TYPE_COMPLETE:
               this.m_actionName = TUpgradeStorage.ACTION_CANCEL_UPGRADE_STORAGE;
               break;
            case TUpgradeStorage.TYPE_UPDATE:
            default:
               this.m_actionName = TUpgradeStorage.ACTION_GET_STORAGE_INFO;
         }
      }
      
      override public function perform() : void
      {
         signedWorldAction(this.m_actionName,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var time:Number = NaN;
         var upgradeInfo:Object = null;
         var discount:int = 0;
         var itemPurchased:FarmItem = null;
         var upgrade:Object = null;
         var idx:String = null;
         if(result != null)
         {
            time = GlobalEngine.serverTime * 1000;
            upgradeInfo = new Object();
            switch(this.m_type)
            {
               case TUpgradeStorage.TYPE_CANCEL:
               case TUpgradeStorage.TYPE_COMPLETE:
                  Global.player.upgradeStatus.isActive = false;
                  break;
               case TUpgradeStorage.TYPE_PURCHASE:
                  logEvent(this.m_building.getItem().getCashName());
                  if(this.m_building.getItem().name.indexOf("chickencoop") >= 0)
                  {
                     itemPurchased = Global.farmGameSettingsManager.getFarmItemByName(this.m_building.getItem().getCashName());
                  }
                  else
                  {
                     itemPurchased = Global.farmGameSettingsManager.getFarmItemByName(this.m_building.getItem().getExpansion());
                  }
                  discount = int(Global.player.upgradeStatus.numHelped);
                  discount += this.m_discount;
                  if(Global.player.tryBuy(this.m_building,false,itemPurchased,discount))
                  {
                     upgrade = new Object();
                     upgrade.isActive = true;
                     upgrade.buildingId = this.m_building.getId();
                     upgrade.url = String(result.helperURL);
                     if(result.worldType != null)
                     {
                        upgrade.worldType = result.worldType;
                     }
                     upgrade.numHelped = 0;
                     Global.player.upgradeStatus.isActive = false;
                  }
                  break;
               case TUpgradeStorage.TYPE_UPGRADE:
                  upgradeInfo.lastClientUpdate = time;
               case TUpgradeStorage.TYPE_UPDATE:
                  if(result.helperURL)
                  {
                     upgradeInfo.isActive = true;
                     upgradeInfo.url = String(result.helperURL);
                     upgradeInfo.numHelped = int(result.numHelped);
                     upgradeInfo.helpers = [];
                     upgradeInfo.lastPosted = result.lastPosted;
                     for(idx in result.helperList)
                     {
                        upgradeInfo.helpers.push(result.helperList[idx]);
                     }
                     upgradeInfo.buildingId = int(result.buildingId);
                     upgradeInfo.worldType = result.worldType;
                     upgradeInfo.expires = int(result.expires);
                     if(upgradeInfo.lastClientUpdate != time)
                     {
                        upgradeInfo.lastClientUpdate = Number(result.clientUpdated);
                        if(Global.player.upgradeStatus.hasOwnProperty("initialUpdateTs"))
                        {
                           upgradeInfo.initialUpdateTs = Global.player.upgradeStatus.initialUpdateTs;
                        }
                        else
                        {
                           upgradeInfo.initialUpdateTs = upgradeInfo.lastClientUpdate;
                        }
                     }
                  }
                  else
                  {
                     upgradeInfo.buildingId = int(this.m_building.getId());
                     upgradeInfo.isActive = false;
                  }
                  Global.player.upgradeStatus = upgradeInfo;
            }
            if(this.m_storageDialog)
            {
               this.m_storageDialog.refreshLayout(true);
            }
            if(this.m_callback != null)
            {
               this.m_callback();
            }
         }
      }
   }
}

