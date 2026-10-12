package Classes
{
   import Classes.Constants.BlossomConstants;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.UI;
   import Managers.FlowerShackManager;
   import Managers.FreezeManager;
   import Transactions.TFlowerShackNuture;
   import flash.events.MouseEvent;
   
   public class FlowerShackFeatureBuilding extends FeatureBuilding
   {
      
      protected const NUTURE_SINGLE:String = "nuture";
      
      protected const NUTURE_ALL:String = "nutureAll";
      
      public function FlowerShackFeatureBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function determineState(delta:Number) : void
      {
         var visit:Boolean = Global.worldManager.isVisiting();
         if(Boolean(witherer) && witherer.isWithered())
         {
            setState(STATE_WITHERED);
         }
         else
         {
            setState(STATE_RIPE);
         }
      }
      
      override public function onClick() : void
      {
         onMouseOut();
         if(!hasValidId())
         {
            showObjectBusy();
         }
         else if(isWithered())
         {
            m_menuItems = [];
            this.showMenu();
         }
         else
         {
            m_menuItems = [];
            if(canShowMoveMenuItem() && isMovable())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Move"),
                  "action":MOVE_OBJECT
               });
            }
            if(getItem().allowDelete && canShowSellMenuItem())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Sell"),
                  "action":SELL_OBJECT
               });
            }
            if(!FreezeManager.isAnythingFrozen())
            {
               UI.displayMenu(m_menuItems,this.onMenuClick);
            }
         }
      }
      
      override public function showMenu() : void
      {
         if(this.state == STATE_BUSY || !Global.worldManager.isWorldSwapStable)
         {
            showObjectBusy();
         }
         else
         {
            super.showMenu();
         }
      }
      
      override public function sortMenu() : void
      {
         for(var menuIdx:int = 0; menuIdx < m_menuItems.length; menuIdx++)
         {
            if(m_menuItems[menuIdx]["action"] == MOVE_OBJECT)
            {
               m_menuItems.splice(menuIdx,1);
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         var currentSuffixNum:int = getCurrentSuffix();
         switch(state)
         {
            case STATE_WITHERED:
               imageName = "built_" + currentSuffixNum;
               m_arrow = null;
               m_arrowArt = null;
               break;
            case STATE_RIPE:
               imageName = "built_" + currentSuffixNum;
               m_arrow = null;
               m_arrowArt = null;
               break;
            default:
               imageName = super.getCurrentImageName();
         }
         return imageName;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.NUTURE_SINGLE:
                  this.nutureSingleBlossomOrBoquet();
                  break;
               case this.NUTURE_ALL:
                  FlowerShackManager.getInstance(m_item.featureName).nutureAllWindow();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
         if(contextMenu != null)
         {
            contextMenu.onMenuClick(event);
         }
      }
      
      override protected function getWitherDelta(plantTime:Number, x_coord:Number, y_coord:Number, witherTime:Number = -1) : Number
      {
         return witherTime;
      }
      
      protected function nutureSingleBlossomOrBoquet() : void
      {
         var currencyName:String = FlowerShackManager.getInstance(m_item.featureName).currencyName;
         var currencyQty:int = Global.player.getWorldCurrencyTotal(currencyName);
         var nectarCost:int = FlowerShackManager.BLOSSOM_COST;
         if(m_item.subType == BlossomConstants.FULL_BLOSSOM_SUBTYPE)
         {
            nectarCost = FlowerShackManager.BOQUET_COST;
         }
         if(currencyQty > nectarCost)
         {
            addTransaction(new TFlowerShackNuture(this,m_item.subType),true);
            super.setFullGrown();
            Global.player.updateWorldCurrency(currencyName,nectarCost * -1);
            displayStatus(ZLocUtils.t("FarmGame","Status_BuyObject",{
               "coinNum":nectarCost,
               "currency":ZLocUtils.t("FarmGame",currencyName),
               "xpNum":0
            }));
         }
         else
         {
            FlowerShackManager.getInstance(m_item.featureName).buyNecatarWindow();
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         var nectarCost:int = 0;
         if(Global.worldManager.isWorldSwapStable)
         {
            switch(state)
            {
               case STATE_WITHERED:
                  toolTip = null;
                  nectarCost = FlowerShackManager.BLOSSOM_COST;
                  if(m_item.subType == BlossomConstants.FULL_BLOSSOM_SUBTYPE)
                  {
                     nectarCost = FlowerShackManager.BOQUET_COST;
                  }
                  toolTip = ZLocUtils.t("Dialogs","flowershack_toolTip_Withered",{"quantity":nectarCost});
                  setToolTip(toolTip);
                  updateToolTipPosition();
                  break;
               default:
                  super.updateToolTipText();
            }
         }
      }
   }
}

