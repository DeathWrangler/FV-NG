package Widgets.Frames.Instagrow
{
   import Classes.util.DisplayObjectUtils;
   import Classes.util.ZLocUtils;
   import Managers.MapResourceHelper;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class InstagrowSelectionFrame extends ZwFrame
   {
      
      private var m_isSelected:Boolean = true;
      
      private var m_checkMark:FarmAnimatedTextButton;
      
      private var m_hasAvailable:Boolean = true;
      
      private var m_costIsFree:Boolean = false;
      
      private var m_imageFrame:ZwButton = null;
      
      private var m_callback:Function = null;
      
      public var m_costText:ZwTextField;
      
      private var active_element:MovieClip;
      
      public function InstagrowSelectionFrame(element:DisplayObject, instagrowHelperType:uint, costAmount:int, callback:Function = null, costIsFree:Boolean = false)
      {
         var typeLabel:String = null;
         var priceText:String = null;
         var image:MovieClip = null;
         var message:String = null;
         var inactive_element:MovieClip = null;
         var titleLabel:String = null;
         super(element);
         this.m_callback = callback;
         this.m_costIsFree = costIsFree;
         this.m_hasAvailable = costAmount > 0;
         if(this.m_hasAvailable)
         {
            if(instagrowHelperType == MapResourceHelper.TYPE_PLOTS)
            {
               this.m_imageFrame = new ZwButton(m_element.cropsActive_mc,this.onClick);
               this.active_element = m_element.cropsActive_mc;
            }
            else if(instagrowHelperType == MapResourceHelper.TYPE_TREES)
            {
               this.m_imageFrame = new ZwButton(m_element.treesActive_mc,this.onClick);
               this.active_element = m_element.treesActive_mc;
            }
            else if(instagrowHelperType == MapResourceHelper.TYPE_ANIMALS)
            {
               this.m_imageFrame = new ZwButton(m_element.animalsActive_mc,this.onClick);
               this.active_element = m_element.animalsActive_mc;
            }
            else if(instagrowHelperType == MapResourceHelper.TYPE_BLOOMS)
            {
               this.m_imageFrame = new ZwButton(m_element.bloomsActive_mc,this.onClick);
               this.active_element = m_element.bloomsActive_mc;
            }
            addWidget(this.m_imageFrame);
            typeLabel = ZLocUtils.t("Dialogs","Instagrow_type_" + MapResourceHelper.getCounterName(instagrowHelperType) + "_friendlyName") + ": ";
            addWidget(new ZwTextField(this.active_element.title_tf,typeLabel));
            if(!this.active_element.image_mc)
            {
               image = new MovieClip();
               image.name = "image_mc";
               this.active_element.addChild(image);
               this.active_element["image_mc"] = image;
            }
            addWidget(new ZwFrame(this.active_element.image_mc));
            addWidget(new ZwFrame(this.active_element.buyInfo_mc));
            priceText = this.m_costIsFree ? ZLocUtils.t("Dialogs","Free") : costAmount.toString();
            this.m_costText = new ZwTextField(this.active_element.buyInfo_mc.farmCash_tf,priceText);
            addWidget(this.m_costText);
            if(this.active_element.buyInfo_mc.check_mc)
            {
               this.m_checkMark = new FarmAnimatedTextButton(this.active_element.buyInfo_mc.check_mc,"",null);
               (this.m_checkMark.element as MovieClip).mouseEnabled = false;
               addWidget(this.m_checkMark);
            }
            if(this.active_element.buyInfo_mc.text_tf)
            {
               addWidget(new ZwTextField(this.active_element.buyInfo_mc.text_tf,ZLocUtils.t("Dialogs","Selected")));
            }
         }
         else
         {
            this.m_isSelected = false;
            if(instagrowHelperType == MapResourceHelper.TYPE_PLOTS)
            {
               this.m_imageFrame = new ZwButton(m_element.cropsInactive_mc,this.onClick);
               inactive_element = m_element.cropsInactive_mc;
               message = ZLocUtils.t("Dialogs","InstantGrow_DialogNoGrowHeaderCrops");
            }
            else if(instagrowHelperType == MapResourceHelper.TYPE_TREES)
            {
               this.m_imageFrame = new ZwButton(m_element.treesInactive_mc,this.onClick);
               inactive_element = m_element.treesInactive_mc;
               message = ZLocUtils.t("Dialogs","InstantGrow_DialogNoGrowHeaderTrees");
            }
            else if(instagrowHelperType == MapResourceHelper.TYPE_ANIMALS)
            {
               this.m_imageFrame = new ZwButton(m_element.animalsInactive_mc,this.onClick);
               inactive_element = m_element.animalsInactive_mc;
               message = ZLocUtils.t("Dialogs","InstantGrow_DialogNoGrowHeaderAnimals");
            }
            else if(instagrowHelperType == MapResourceHelper.TYPE_BLOOMS)
            {
               this.m_imageFrame = new ZwButton(m_element.animalsInactive_mc,this.onClick);
               inactive_element = m_element.animalsInactive_mc;
               message = ZLocUtils.t("Dialogs","InstantGrow_DialogNoGrowHeaderBlooms");
            }
            addWidget(this.m_imageFrame);
            titleLabel = ZLocUtils.t("Dialogs","Instagrow_type_" + MapResourceHelper.getCounterName(instagrowHelperType) + "_friendlyName") + ": ";
            addWidget(new ZwTextField(inactive_element.title_tf,titleLabel));
            addWidget(new ZwTextField(inactive_element.text_tf,message));
         }
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(this.m_checkMark != null)
         {
            this.m_checkMark.visible = !this.m_checkMark.visible;
         }
         if(this.m_callback != null)
         {
            this.m_callback(event);
         }
      }
      
      public function getSelected() : Boolean
      {
         var result:Boolean = false;
         if(this.m_checkMark != null)
         {
            result = this.m_checkMark.element != null && this.m_checkMark.visible;
         }
         else
         {
            result = this.haveThisResource();
         }
         return result;
      }
      
      public function setSelected(isSelected:Boolean) : void
      {
         if(this.m_hasAvailable)
         {
            this.m_isSelected = isSelected;
            if(this.m_checkMark != null)
            {
               this.m_checkMark.visible = this.m_isSelected;
            }
            this.applyGrayOut = !this.m_isSelected;
         }
      }
      
      public function haveThisResource() : Boolean
      {
         return this.m_hasAvailable;
      }
      
      private function set applyGrayOut(onOff:Boolean) : void
      {
         var element:Sprite = this.m_imageFrame.element as Sprite;
         if(element)
         {
            DisplayObjectUtils.grayOut(element,onOff);
         }
      }
      
      public function updateCost(costAmount:String) : void
      {
         var priceText:String = this.m_costIsFree ? ZLocUtils.t("Dialogs","Free") : costAmount.toString();
         if(this.m_costText)
         {
            this.m_costText.text = priceText;
         }
      }
   }
}

