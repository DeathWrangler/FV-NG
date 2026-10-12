package Widgets.Windows.Orchards
{
   import Classes.OrchardBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public final class SuperOrchardsOnboardingWindow extends FarmWindow
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_SuperOrchard_Onboard.swf";
      
      private var m_orchardBuilding:OrchardBuilding;
      
      public function SuperOrchardsOnboardingWindow(orchardBuilding:OrchardBuilding)
      {
         this.m_orchardBuilding = orchardBuilding;
         super(DIALOG_ASSET);
      }
      
      private function getExpansionName(item:FarmItem) : String
      {
         var expansionName:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            expansionName = item.getStringFromDataSource("expansion");
         }
         else
         {
            expansionName = item.xml.expansion;
         }
         return expansionName;
      }
      
      override protected function postLoadComplete() : void
      {
         var expansionItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getExpansionName(this.m_orchardBuilding.getItem()));
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","SuperOrchardOnboard_Title")));
         }
         if(m_window.default_tf)
         {
            addWidget(new ZwTextField(m_window.default_tf,ZLocUtils.t("Dialogs","SuperOrchardOnboard_Text")));
         }
         if(Boolean(m_window.expand_bt) && this.m_orchardBuilding.isExpandable() == true)
         {
            addWidget(new FarmAnimatedTextButton(m_window.expand_bt,ZLocUtils.t("Dialogs","SuperOrchardOnboard_Expand",{"price":expansionItem.cash.toString()}),this.onExpandOrchard));
         }
         if(m_window.expandAll_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.expandAll_bt,ZLocUtils.t("Dialogs","SuperOrchardOnboard_ExpandAll"),this.onExpandAllOrchards));
         }
      }
      
      private function upgradeSingleOrchard(event:GenericPopupEvent) : void
      {
         var expansionItem:FarmItem = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            expansionItem = Global.farmGameSettingsManager.getFarmItemByName(this.getExpansionName(this.m_orchardBuilding.getItem()));
            this.m_orchardBuilding.upgradeOrchard();
            this.close();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
      
      private function upgradeAllOrchards(event:GenericPopupEvent) : void
      {
         var expansionItem:FarmItem = null;
         var orchardArray:Array = null;
         var cashSpentForExpandOrchards:Number = NaN;
         var cashReqdForEachUpgrade:Number = NaN;
         var orchard:OrchardBuilding = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            expansionItem = Global.farmGameSettingsManager.getFarmItemByName(this.getExpansionName(this.m_orchardBuilding.getItem()));
            orchardArray = Global.world.getObjectsByClass(OrchardBuilding);
            cashSpentForExpandOrchards = Global.player.cash;
            cashReqdForEachUpgrade = expansionItem.cash;
            if(this.checkIfEnoughCashForExpandAll() == true)
            {
               for each(orchard in orchardArray)
               {
                  if(orchard.isExpandable() == true)
                  {
                     orchard.upgradeOrchard(false);
                  }
               }
               TransactionManager.sendAllTransactions(true);
            }
            this.close();
         }
      }
      
      private function checkIfEnoughCashForExpandAll() : Boolean
      {
         var orchard:OrchardBuilding = null;
         var cashRequired:Number = NaN;
         var canExpand:Boolean = false;
         var orchardArray:Array = Global.world.getObjectsByClass(OrchardBuilding);
         var expansionItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getExpansionName(this.m_orchardBuilding.getItem()));
         var numOrchards:Number = 0;
         for each(orchard in orchardArray)
         {
            if(orchard.isExpandable() == true)
            {
               numOrchards++;
            }
         }
         cashRequired = expansionItem.cash * numOrchards;
         return Global.player.canBuyCash(cashRequired,true);
      }
      
      private function onExpandOrchard(event:Event) : void
      {
         var expansionItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getExpansionName(this.m_orchardBuilding.getItem()));
         UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","SuperOrchardOnboard_BuyConfirm",{
            "quantity":1,
            "item":ZLocUtils.tk_pk(expansionItem.friendlyName,"",1),
            "price":expansionItem.cash.toString()
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.upgradeSingleOrchard),false);
      }
      
      private function onExpandAllOrchards(event:Event) : void
      {
         var orchard:OrchardBuilding = null;
         var orchardArray:Array = Global.world.getObjectsByClass(OrchardBuilding);
         var numOrchards:int = 0;
         var expansionItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getExpansionName(this.m_orchardBuilding.getItem()));
         for each(orchard in orchardArray)
         {
            if(orchard.isExpandable() == true)
            {
               numOrchards++;
            }
         }
         UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","SuperOrchardOnboard_BuyConfirm",{
            "quantity":numOrchards,
            "item":ZLocUtils.tk_pk(expansionItem.friendlyName,"",numOrchards),
            "price":expansionItem.cash * numOrchards
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.upgradeAllOrchards),false);
      }
   }
}

