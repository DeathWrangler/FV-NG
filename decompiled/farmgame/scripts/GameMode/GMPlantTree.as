package GameMode
{
   import Classes.Constants.Experiments;
   import Classes.FarmGameObject;
   import Classes.IOrchardBuilding;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.ZapFirstPlacementDialogTask;
   import Classes.MapResource;
   import Classes.Tree;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Managers.FarmGameSettingsManager;
   import Transactions.TPlant;
   import Widgets.Constants.Market.Currency;
   import flash.events.MouseEvent;
   
   public class GMPlantTree extends GMObjectMove
   {
      
      private var m_treeType:String;
      
      private var m_tree:Tree;
      
      public function GMPlantTree(treeType:String, isGift:Boolean = false, buildingId:Number = 0, shouldReopenGift:Boolean = true, currency:String = "")
      {
         this.m_treeType = treeType;
         m_isGift = isGift;
         m_cid = buildingId;
         m_storedOrigin = buildingId;
         super(null,null,isGift,shouldReopenGift,false,currency);
         if(Global.flashHotParams["MP_SELECTED_INITIALIZED_ON_CONSTRUCTOR"])
         {
            this.createSelectedObject();
         }
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!Global.flashHotParams["MP_SELECTED_INITIALIZED_ON_CONSTRUCTOR"])
         {
            this.createSelectedObject();
         }
         return super.onMouseMove(event);
      }
      
      protected function createSelectedObject() : void
      {
         if(!m_selectedObject)
         {
            m_highlightedPoint = getMouseTilePos();
            this.m_tree = new Tree(this.m_treeType);
            this.m_tree.setOuter(Global.world);
            this.m_tree.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
            m_selectedObject = this.m_tree as FarmGameObject;
         }
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         var originObject:WorldObject = null;
         var treeItem:FarmItem = null;
         var actionBundle:String = null;
         var images:Array = null;
         var canBuyAnother:Boolean = false;
         var variant:int = 0;
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            if(Global.world.checkNumObjectLimit())
            {
               Global.world.setDefaultGameMode();
               if(!m_storedOrigin)
               {
                  treeItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_treeType);
                  if(Boolean(treeItem && treeItem.type == "tree") && Boolean(m_isGift == false) && Global.player.tryBuy(m_selectedObject as MapResource,m_isGift,null,0,"",this.m_currency))
                  {
                     if(FarmGameSettingsManager.isInDataSourceExperiment())
                     {
                        actionBundle = treeItem.getStringFromDataSource("actionBundle");
                     }
                     else
                     {
                        actionBundle = treeItem.xml.@actionBundle.toString();
                     }
                     if(actionBundle != "")
                     {
                        images = [{
                           "src":treeItem.getImageByName("icon"),
                           "href":"{SN_APP_URL}{creative:picture}index.php"
                        }];
                     }
                     if(treeItem.multiplace && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) < Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
                     {
                        canBuyAnother = false;
                        if(this.m_currency == Currency.CASH)
                        {
                           canBuyAnother = Global.player.canBuyCash(treeItem.cash,false);
                        }
                        else
                        {
                           canBuyAnother = Global.player.canBuyWithCurrency(this.m_currency,treeItem.realCost,false);
                        }
                        if(canBuyAnother)
                        {
                           Global.world.popGameMode();
                           Global.world.addGameMode(new GMPlantTree(this.m_treeType,m_isGift,m_storedOrigin,true,this.m_currency));
                        }
                     }
                  }
               }
               this.m_tree.addTransaction(new TPlant(this.m_tree,m_isGift,0,0,null,m_storedOrigin,this.m_currency));
               IdleTaskQueue.getInstance().addTask(new ZapFirstPlacementDialogTask(this.m_treeType));
               originObject = m_storedOrigin ? Global.world.getObjectById(m_storedOrigin) : null;
               if(Boolean(originObject) && originObject is IOrchardBuilding)
               {
                  (originObject as IOrchardBuilding).displayStorageDialog();
               }
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","Maxed_Objects_Full"));
               Global.world.addGameMode(this);
            }
         }
         else if((m_selectedObject as MapResource).fromMarket)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_RETENTION_CORE_CLICK_FLOW_IMPROVEMENT);
            if(variant == 3 || variant == 4 || variant == 7 || variant == 8)
            {
               Global.world.addGameMode(this.getMultiPlaceGameMode());
            }
         }
         return true;
      }
      
      protected function getMultiPlaceGameMode() : GameMode
      {
         return new GMPlantTree(this.m_treeType,m_isGift,m_cid,false,this.m_currency);
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
      }
   }
}

