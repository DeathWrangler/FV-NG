package Widgets.Slots.Breeding
{
   import Classes.Animal;
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Engine.Constants;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.MovieClipTooltip;
   import Widgets.Windows.StorageContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class RandomPlacementContentsSlot extends ZwSlotFrame
   {
      
      private static const TOOLTIP_ICON_SIZE:int = 32;
      
      private var m_friendUID:String = "0";
      
      private var m_friendText:ZwTextField = null;
      
      private var m_parentWindow:StorageContentsWindow;
      
      protected var m_popupIcon:FarmIcon = null;
      
      protected var m_farmItem:FarmItem = null;
      
      protected var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_animalSprite:Sprite = null;
      
      private const TOOLTIP_NUM_FRAMES:int = 30;
      
      private const TOOLTIP_STOP_FRAME:int = 8;
      
      private var m_frontRowSize:int;
      
      private var m_slotIndex:int;
      
      public function RandomPlacementContentsSlot(element:DisplayObject, parentWindow:StorageContentsWindow, index:int = 0, frontRowSize:int = 0)
      {
         var height:int = 0;
         var width:int = 0;
         super(element);
         this.m_frontRowSize = frontRowSize;
         this.m_slotIndex = index;
         this.m_parentWindow = parentWindow;
         this.attachTooltip(new MovieClipTooltip(element as MovieClip,this.TOOLTIP_NUM_FRAMES));
         if(m_element.hasOwnProperty("tooltip_mc") && Boolean(m_element.tooltip_mc.hasOwnProperty("tooltipIcon_mc")))
         {
            this.m_popupIcon = new FarmIcon(m_element.tooltip_mc.tooltipIcon_mc);
            height = m_element.tooltip_mc.tooltipIcon_mc.height ? int(m_element.tooltip_mc.tooltipIcon_mc.height) : TOOLTIP_ICON_SIZE;
            width = m_element.tooltip_mc.tooltipIcon_mc.width ? int(m_element.tooltip_mc.tooltipIcon_mc.height) : TOOLTIP_ICON_SIZE;
            this.m_popupIcon.setIconSize(width,height);
            addWidget(this.m_popupIcon);
         }
      }
      
      override public function release() : void
      {
         this.m_objectPreviewFrame = null;
         this.m_parentWindow = null;
         this.m_animalSprite = null;
         this.m_popupIcon = null;
         this.m_farmItem = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var holder:MovieClip = null;
         var animal:Animal = null;
         var rotate:int = 0;
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         if(this.m_objectPreviewFrame != null)
         {
            removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_farmItem.displayLoader.canUseAnimation)
         {
            this.m_farmItem.displayLoader.useAnimation = true;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            holder = m_element.icon_mc;
            animal = new Animal(this.m_farmItem.name);
            rotate = Math.random() * Constants.ROTATION_MAX;
            animal.drawDisplayObject();
            if(Boolean(holder) && holder.width > 0)
            {
               this.m_objectPreviewFrame = new ObjectPreviewFrame(holder,this.m_farmItem,null,null,[holder.width],"","",animal);
            }
            else if(this.m_slotIndex < this.m_frontRowSize)
            {
               this.m_objectPreviewFrame = new ObjectPreviewFrame(holder,this.m_farmItem,null,[4],null,"","",animal);
            }
            else
            {
               this.m_objectPreviewFrame = new ObjectPreviewFrame(holder,this.m_farmItem,null,[2],null,"","",animal);
            }
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_objectPreviewFrame,true);
            this.m_animalSprite = this.m_objectPreviewFrame.sprite;
            if(Boolean(this.m_animalSprite) && data.quantity > 0)
            {
               this.m_animalSprite.buttonMode = true;
               this.m_animalSprite.mouseChildren = true;
               this.m_animalSprite.useHandCursor = false;
            }
         }
         if(data.friend)
         {
            this.m_friendUID = data.friend;
         }
         this.setupTooltip();
      }
      
      protected function setupTooltip() : void
      {
         var number:String = null;
         var friend:Friend = null;
         var show:Boolean = false;
         if(this.m_friendUID)
         {
            number = this.m_friendUID as String;
            friend = Global.friendManager.getFriendData(number);
            if(friend)
            {
               show = false;
               if(friend.picture)
               {
                  if(this.m_popupIcon != null)
                  {
                     show = true;
                     this.m_popupIcon.visible = true;
                     if(this.m_popupIcon.getIconWidth() != TOOLTIP_ICON_SIZE)
                     {
                        this.m_popupIcon.setIconSize(TOOLTIP_ICON_SIZE,TOOLTIP_ICON_SIZE);
                     }
                     this.m_popupIcon.loadIcon(friend.picture);
                  }
               }
               if(friend.firstName)
               {
                  if(m_element.tooltip_mc.generic_tf)
                  {
                     show = true;
                     removeWidget(m_element.tooltip_mc.generic_tf);
                     this.m_friendText = addWidget(new ZwTextField(m_element.tooltip_mc.generic_tf,"From: " + friend.firstName)) as ZwTextField;
                     this.m_friendText.visible = true;
                  }
               }
               if(!show)
               {
                  (m_element.tooltip_mc as DisplayObject).visible = false;
               }
               else if(m_element.hasOwnProperty("tooltip_mc"))
               {
                  (m_element.tooltip_mc as MovieClip).gotoAndStop(this.TOOLTIP_STOP_FRAME);
               }
            }
         }
         else
         {
            if(m_element.hasOwnProperty("tooltip_mc"))
            {
               (m_element.tooltip_mc as DisplayObject).visible = false;
            }
            if(this.m_popupIcon != null)
            {
               this.m_popupIcon.visible = false;
            }
         }
      }
   }
}

