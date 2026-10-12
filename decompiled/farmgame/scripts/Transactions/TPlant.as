package Transactions
{
   import Classes.HarvestableResource;
   import Classes.Tree;
   import Classes.ZItem.FarmItem;
   import Classes.util.LEUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.ItemMembershipManager;
   
   public class TPlant extends TWorldState
   {
      
      protected var m_params:Object;
      
      private var m_resource:HarvestableResource;
      
      private var m_wishBundle:Object;
      
      public function TPlant(resource:HarvestableResource, isGift:Boolean = false, energySource:int = 0, energy:Number = 0, energyMetadata:Object = null, containerId:Number = 0, currency:String = "", aoeSources:Array = null)
      {
         super(resource);
         this.m_resource = resource;
         this.m_params = new Object();
         this.m_params.isGift = isGift;
         this.m_params.energyCost = energy;
         this.m_params.energySource = energySource;
         this.m_params.energyMetadata = energyMetadata;
         this.m_params.isStorageWithdrawal = containerId;
         this.m_params.currency = currency;
         this.m_params.aoeSources = aoeSources;
         if(this.m_params.isGift == true)
         {
            Global.player.removeGift(resource);
         }
         LEUtil.handleLETransactionStart(this.m_resource.getItem());
      }
      
      override public function perform() : void
      {
         signedWorldAction(TPlace.ACTION_PLACE,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var seedPackage:String = null;
         if(Boolean(result) && result.hasOwnProperty("bigPlot"))
         {
            this.m_resource.isBigPlot = result.bigPlot;
         }
         if(Boolean(result) && result.hasOwnProperty("isProduceItem"))
         {
            this.m_resource.isProduceItem = result.isProduceItem;
         }
         if(Boolean(result) && result.hasOwnProperty("usedLastStoredSeed"))
         {
            if(result.usedLastStoredSeed.hasOwnProperty("seedWishData"))
            {
               this.m_wishBundle = {
                  "item_name":result.usedLastStoredSeed.seedWishData.item_name,
                  "wish_granted_link":result.usedLastStoredSeed.seedWishData.wish_granted_link,
                  "actor":result.usedLastStoredSeed.seedWishData.actor,
                  "key":result.usedLastStoredSeed.seedWishData.key,
                  "images":[{
                     "href":"{SN_APP_URL}" + result.usedLastStoredSeed.seedWishData.wish_granted_link,
                     "src":Global.getAssetURL(result.usedLastStoredSeed.seedWishData.image)
                  }]
               };
               seedPackage = "";
               if(FarmGameSettingsManager.isInDataSourceExperiment())
               {
                  seedPackage = this.m_resource.getItem().getStringFromDataSource("seedpackage");
               }
               else
               {
                  seedPackage = this.m_resource.getItem().xml.seedpackage;
               }
               FarmStatsManager.count("giftable_seeds",seedPackage,"seeding_ran_out_of_seeds");
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","BuySeedPackages_OutOfSeeds",{"item":ZLocUtils.tk_pk(result.usedLastStoredSeed.seedWishData.item_name)}),GenericPopup.TYPE_SHARE,this.onCloseShareWishDialog));
            }
         }
         var item:FarmItem = this.m_resource.getItem() as FarmItem;
         LEUtil.handleLETransactionComplete(result,item);
         if(this.m_resource is Tree)
         {
            ItemMembershipManager.conditionallyOnboard(ItemMembershipManager.FEATURE_NAME_TREE);
         }
      }
      
      public function onCloseShareWishDialog(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && Boolean(this.m_wishBundle))
         {
            GlobalEngine.socialNetwork.publishFeedStory("Wishlist_Giftableseeds_Prompt",this.m_wishBundle,[],false,null);
         }
         this.m_wishBundle = null;
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = TPlace.ACTION_PLACE;
         result.item = this.m_resource.getItem();
         result.isStorageWithdrawl = this.m_params.isStorageWithdrawal;
         result.params = this.m_params;
         return result;
      }
   }
}

