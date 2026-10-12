package Widgets.Slots.Breeding
{
   import Classes.AnimalBreedingConfigSettings;
   import Classes.Collections.AnimalBreedingCollection;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.BreedingCollectionFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   
   public class BreedingCollectionColorSlot extends ZwSlotFrame
   {
      
      private var m_breedingCollectionFrame:BreedingCollectionFrame;
      
      private var m_colorName:ZwTextField;
      
      private var m_colorDot:FarmAnimatedTextButton;
      
      private var m_activeCollection:AnimalBreedingCollection;
      
      private var m_colorBrush:ZwBaseWidget;
      
      public function BreedingCollectionColorSlot(element:DisplayObject, breedingCollectionFrame:BreedingCollectionFrame)
      {
         super(element);
         this.m_breedingCollectionFrame = breedingCollectionFrame;
         addWidget(this.m_colorName = new ZwTextField(m_element.generic_tf));
         addWidget(this.m_colorDot = new FarmAnimatedTextButton(m_element.colorDot_mc,"",this.onChangeColor));
      }
      
      override public function populate(data:Object) : void
      {
         var colorObject:Object = null;
         var baseHSV:Array = null;
         var colorRGB:Array = null;
         var colorMatrix:Array = null;
         var colorMatrixFilter:ColorMatrixFilter = null;
         if(data != null && data.hasOwnProperty("colorName") && data.hasOwnProperty("animalCollection"))
         {
            this.m_activeCollection = data.animalCollection as AnimalBreedingCollection;
            this.m_colorName.text = ZLocUtils.t("FarmGame",data.colorName + "Color");
            colorObject = Global.animalBreedingSettings.getColorObj(data.colorName as String);
            baseHSV = [parseInt(colorObject[MutableAnimalState.HUE_DATA_KEY][0],AnimalBreedingConfigSettings.DEFAULT_HEX_RADIX) / 40,parseInt(colorObject[MutableAnimalState.SATURATION_DATA_KEY][0],AnimalBreedingConfigSettings.DEFAULT_HEX_RADIX) / 15,parseInt(colorObject[MutableAnimalState.INTENSITY_DATA_KEY][0],AnimalBreedingConfigSettings.DEFAULT_HEX_RADIX) / 15];
            colorRGB = FarmGameUtil.hsvToRgb(baseHSV[0],baseHSV[1],baseHSV[2]);
            colorMatrix = [colorRGB[0],0,2.64,0,0,colorRGB[1],1,1.9,0,0,colorRGB[2],0,1.2,0,0,0,0,0,1,0];
            colorMatrixFilter = new ColorMatrixFilter(colorMatrix);
            (this.m_colorDot.element as MovieClip).filters = [colorMatrixFilter];
            this.m_colorDot.visible = true;
            this.m_colorName.visible = true;
         }
      }
      
      private function onChangeColor(event:Event) : void
      {
         this.m_breedingCollectionFrame.activeCollection = this.m_activeCollection;
      }
   }
}

