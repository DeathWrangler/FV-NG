package Widgets.Slots.Crafting
{
   import Classes.Constants.Experiments;
   import flash.display.DisplayObject;
   
   public class DragonLairRecipeSlot extends LabRecipeSlot
   {
      
      private var m_showBuyButton:Boolean;
      
      public function DragonLairRecipeSlot(element:DisplayObject, callBackObject:Object, labConfig:XML)
      {
         var dragonLairVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DRAGON_BUY_SCALES);
         switch(dragonLairVariant)
         {
            case Experiments.DRAGON_VARIANT_1:
            case Experiments.DRAGON_VARIANT_2:
               this.m_showBuyButton = false;
               break;
            case Experiments.DRAGON_VARIANT_3:
            case Experiments.DRAGON_VARIANT_4:
               this.m_showBuyButton = true;
         }
         super(element,callBackObject,labConfig);
      }
      
      override public function updateSubSlots(data:Object, showIndividualBuyButtons:Boolean = true) : void
      {
         super.updateSubSlots(data,this.m_showBuyButton);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
      }
   }
}

