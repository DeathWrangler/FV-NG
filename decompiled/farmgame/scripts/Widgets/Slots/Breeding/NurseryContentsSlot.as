package Widgets.Slots.Breeding
{
   import Classes.BuildingItemUseMediator;
   import Classes.BuildingPart;
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Breeding.BaseContentsWindow;
   import Widgets.Windows.Breeding.NurseryContentsWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class NurseryContentsSlot extends AnimalBreedingContentsSlot
   {
      
      protected var m_partButton:FarmAnimatedTextButton;
      
      protected var m_partAmount:ZwTextField = null;
      
      protected var m_data:Object = null;
      
      public function NurseryContentsSlot(element:DisplayObject, parentWindow:BaseContentsWindow)
      {
         super(element,parentWindow);
         this.m_partButton = new FarmAnimatedTextButton(m_element.feed_bt,ZLocUtils.t("Dialogs",parentWindow.building.bldgName + "_addContaineePart"),this.onAddContaineePartClick);
         addWidget(this.m_partButton);
         this.m_partButton.visible = true;
         this.m_partButton.enabled = true;
         this.m_partAmount = new ZwTextField(m_element.feedAmount_tf,"");
         addWidget(this.m_partAmount);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         var hasPart:Boolean = (m_parentWindow as NurseryContentsWindow).containeePartRemaining > 0;
         this.m_partButton.visible = true;
         this.m_partButton.enabled = hasPart && data.quantity > 0 && Boolean(data.metadata);
         var resident:Object = m_parentWindow.building.containeeManager.createResidentInstance(data.code);
         if(Boolean(data.metadata) && data.metadata != "")
         {
            resident.setMetadata(data.metadata);
         }
         this.m_partAmount.visible = true;
         this.updatePartCount(resident as StorageBuilding);
         m_popupIcon.visible = false;
      }
      
      private function updatePartCount(resident:StorageBuilding) : void
      {
         var partCount:int = 0;
         if(resident)
         {
            partCount = resident.count;
         }
         this.m_partAmount.text = partCount.toString() + "/" + resident.capacity;
      }
      
      public function updateButtons() : void
      {
         if(this.m_data)
         {
            this.populate(this.m_data);
         }
      }
      
      public function onAddContaineePartClick(event:MouseEvent) : void
      {
         var resident:Object = null;
         var isGift:Boolean = true;
         var partResource:MapResource = new BuildingPart((m_parentWindow as NurseryContentsWindow).containeePart);
         if(Boolean(m_parentWindow) && Boolean(m_parentWindow.building) && Boolean(m_parentWindow.building.containeeManager))
         {
            m_parentWindow.building.containeeManager.latestSelectedContaineeId = m_farmItem.code;
            m_parentWindow.building.containeeManager.latestSelectedContaineeMetadata = this.m_data.metadata;
            BuildingItemUseMediator.getInstance().mediate(partResource.getItem().name,isGift,m_parentWindow.building,isGift);
            resident = m_parentWindow.building.containeeManager.latestChangedResidentInstance;
            if(resident)
            {
               this.m_data.metadata = resident.getMetadata() as String;
               if(resident.isFullyBuilt())
               {
                  this.m_partButton.enabled = false;
                  m_parentWindow.close();
               }
               else
               {
                  this.populate(this.m_data);
                  (m_parentWindow as NurseryContentsWindow).containeePartCountTextField.text = (m_parentWindow as NurseryContentsWindow).containeePartRemaining.toString();
                  (m_parentWindow as NurseryContentsWindow).updateSlotButtons();
               }
            }
         }
      }
      
      override protected function animalMouseClickHandler(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog",m_parentWindow.building.getItemName(),"remove",m_farmItem.name);
         m_parentWindow.skipCloseStat = true;
         if(m_animalSprite)
         {
            m_animalSprite.removeEventListener(MouseEvent.CLICK,this.animalMouseClickHandler);
            m_animalSprite = null;
         }
         var extraData:Object = new Object();
         extraData.isGift = false;
         extraData.repopGift = false;
         extraData.metadata = this.m_data.metadata;
         m_farmItem.onUse(m_parentWindow.building.getId(),extraData);
         m_parentWindow.close();
      }
   }
}

