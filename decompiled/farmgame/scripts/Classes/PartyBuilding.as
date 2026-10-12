package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.FarmDynamicDialog;
   import Engine.Helpers.Vector3;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.PartyManager;
   import Transactions.TTransformPartyBuilding;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class PartyBuilding extends InteractiveDecoration
   {
      
      private static const STATE_IDLE:String = "Idle";
      
      protected var m_partyState:String = STATE_IDLE;
      
      protected const GOTO_PARTY:String = "gotoParty";
      
      public function PartyBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      public static function displayParyDynamicDialog() : void
      {
         var dialog:FarmDynamicDialog = FarmDynamicDialog.createDialog("newYearsEveParty",FarmDynamicDialog);
         dialog.setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,"titleText");
         dialog.setShortcutAttribute("itemImage",ImageController.ATTRIBUTE_SOURCE,"assets/buildings/bldg_barn_lighted_icon.png");
         dialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,"bodyText");
         dialog.setShortcutAttribute("okayButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Continue"));
         dialog.show();
      }
      
      public function get partyState() : String
      {
         return this.m_partyState;
      }
      
      public function set partyState(state:String) : void
      {
         this.m_partyState = state;
      }
      
      private function get partyCode() : String
      {
         var partyReference:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            partyReference = m_item.getStringFromDataSource("partyReference");
         }
         else
         {
            partyReference = m_item.xml.child("partyReference").toString();
         }
         return partyReference;
      }
      
      override protected function updateToolTipText() : void
      {
         var itemFriendlyName:String = null;
         var currentCount:Number = NaN;
         var maxCount:Number = NaN;
         var guestListText:String = null;
         if(isHighlighted() && Boolean(getItem()))
         {
            itemFriendlyName = getItemFriendlyName();
            currentCount = 0;
            maxCount = 40;
            if(Boolean(PartyManager.getInstance()) && Boolean(PartyManager.getInstance().getPartyObjectByCode(this.partyCode)))
            {
               currentCount = PartyManager.getInstance().getPartyObjectByCode(this.partyCode).friendSet.numFriendsCompleted;
               maxCount = PartyManager.getInstance().getPartyObjectByCode(this.partyCode).goal.getMaximumLevelRequirement();
               if(currentCount > maxCount)
               {
                  currentCount = maxCount;
               }
            }
            guestListText = ZLocUtils.t("Items",getItem().name + "_capacity",{
               "quantity":currentCount,
               "maximum":maxCount
            });
            setToolTip(ZLocUtils.tk_pk_asTitle(itemFriendlyName) + "\n" + guestListText);
            updateToolTipPosition();
         }
      }
      
      override protected function onImageLoaded(event:Event) : void
      {
         var autoActivateDate:String = null;
         var autoDeactivateDate:String = null;
         super.onImageLoaded(event);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            autoActivateDate = m_item.getStringFromDataSource("autoActivateDate");
            autoDeactivateDate = m_item.getStringFromDataSource("autoDeactivateDate");
         }
         else if(m_item.xml.autoActivateDate)
         {
            autoActivateDate = m_item.xml.autoActivateDate.toString();
            autoDeactivateDate = m_item.xml.autoDeactivateDate.toString();
         }
         if(Boolean(autoActivateDate) && FarmGameUtil.checkDateGate(autoActivateDate,autoDeactivateDate))
         {
            activate();
         }
      }
      
      override protected function getMenuItems() : Array
      {
         var menuItem:Object = null;
         var itemName:String = m_item.name;
         var menuArray:Array = [];
         menuArray.push({
            "label":ZLocUtils.t("FarmGame","GoToParty"),
            "action":this.GOTO_PARTY
         });
         var parentMenuItems:Array = super.getMenuItems();
         for each(menuItem in parentMenuItems)
         {
            menuArray.push(menuItem);
         }
         return menuArray;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.GOTO_PARTY:
                  this.displayPartyWindow();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function displayPartyWindow() : void
      {
         if(this.partyCode == "FS01")
         {
            PartyManager.getInstance().displayBuildingPartyWindow(this.partyCode,this);
         }
         else
         {
            PartyManager.getInstance().displayPartyWindow(this.partyCode);
         }
      }
      
      public function transformBuilding() : void
      {
         var tempClass:Class = null;
         var currentItem:FarmItem = getItem();
         var finishedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(currentItem.getFinishedName());
         var currentItemName:String = currentItem.name;
         var currentPosition:Vector3 = this.getPosition();
         var id:Number = this.getId();
         detach();
         if(finishedItem.className != "")
         {
            tempClass = getDefinitionByName("Classes." + finishedItem.className) as Class;
         }
         else
         {
            tempClass = getDefinitionByName("Classes.InteractiveDecoration") as Class;
         }
         var transformedObject:MapResource = new tempClass(finishedItem.name);
         transformedObject.setMetadata(this.getMetadata());
         transformedObject.attachToPersistentData(this.persistentDataKey);
         transformedObject.setOuter(Global.world);
         transformedObject.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
         transformedObject.conditionallyReattach();
         transformedObject.setId(id);
         TransactionManager.addTransaction(new TTransformPartyBuilding(this));
         activate();
      }
   }
}

