package Widgets.Slots
{
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildKeyRequestSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_countTf:ZwTextField;
      
      private var m_giveBt:FarmAnimatedTextButton;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      public function GuildKeyRequestSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("count_tf"))
         {
            addWidget(this.m_countTf = new ZwTextField(m_element["count_tf"],"0"));
         }
         if(m_element.hasOwnProperty("give_bt"))
         {
            addWidget(this.m_giveBt = new FarmAnimatedTextButton(m_element["give_bt"],"Give 1",this.onGiveKeyButtonClick));
            this.m_giveBt.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.index;
         this.m_countTf.text = "Requested : " + this.m_data.request1.toString();
         this.m_countTf.visible = true;
         (m_element as MovieClip).visible = true;
         this.m_giveBt.visible = true;
         if(GuildManager.getInstance().canGiveKey())
         {
            this.m_giveBt.enabled = true;
         }
         else
         {
            this.m_giveBt.enabled = false;
         }
         if(this.m_isIconPreviewAdded == true)
         {
            removeWidget(this.m_iconPreview);
            this.m_iconPreview.detachTooltip();
         }
         var icon:FarmIcon = new FarmIcon(m_element["profile_mc"] as MovieClip,this.m_data.pic_square);
         icon.setIconSize(50,50);
         icon.detachTooltip();
         icon.visible = true;
         if(this.m_data.hasOwnProperty("name") && this.m_data.name != null && this.m_data.name != "")
         {
            if(GuildManager.getInstance().canGiveKey())
            {
               this.m_giveBt.attachTooltip(new FarmTextTooltip("Give 1 key to " + this.m_data.name));
            }
            else
            {
               this.m_giveBt.attachTooltip(new FarmTextTooltip("You do not have enough tokens to help"));
            }
            if(this.m_toolTip)
            {
               this.m_toolTip.setText(this.m_data.name);
            }
            else
            {
               icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(this.m_data.name));
            }
         }
      }
      
      public function onGiveKeyButtonClick(e:Event) : void
      {
         GuildManager.getInstance().giveKey(this.m_data.playerId);
      }
   }
}

