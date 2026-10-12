package Widgets.Slots.Breeding
{
   import Classes.util.ZLocUtils;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.Breeding.BreedingCollectionFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BreedingCollectionSlot extends ZwSlotFrame
   {
      
      private var m_collectionName:FarmAnimatedTextButton;
      
      private var m_breedingFrame:BreedingCollectionFrame;
      
      private var m_collectionId:String;
      
      private var m_checkmark:ZwBaseWidget;
      
      public function BreedingCollectionSlot(element:DisplayObject, breedingFrame:BreedingCollectionFrame)
      {
         super(element);
         this.m_breedingFrame = breedingFrame;
         addWidget(this.m_collectionName = new FarmAnimatedTextButton(m_element.collection_bt,"",this.onCollectionClick));
         addWidget(this.m_checkmark = new ZwBaseWidget(m_element.check_mc));
      }
      
      override public function populate(data:Object) : void
      {
         var collectionName:String = null;
         var featureOption:Object = null;
         if(data != null)
         {
            this.m_collectionId = data as String;
            collectionName = ZLocUtils.t("Dialogs",this.m_collectionId + "_CollectionName");
            if(collectionName == null || collectionName == "")
            {
               collectionName = ZLocUtils.t("Dialogs",this.m_collectionId + "_PatternName");
            }
            this.m_collectionName.text = collectionName;
            this.m_collectionName.visible = true;
            featureOption = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.ANIMAL_BREEDING,this.m_breedingFrame.getFeatureName());
            this.m_checkmark.visible = featureOption != null && featureOption.hasOwnProperty(this.m_collectionId) && featureOption[this.m_collectionId] > 0;
            if(this.m_breedingFrame.activeCollection.name == this.m_collectionId)
            {
               (m_element as MovieClip).gotoAndStop(3);
            }
            else
            {
               (m_element as MovieClip).gotoAndStop(0);
            }
         }
      }
      
      private function onCollectionClick(event:Event) : void
      {
         this.m_breedingFrame.setActiveCollectionByName(this.m_collectionId);
      }
   }
}

