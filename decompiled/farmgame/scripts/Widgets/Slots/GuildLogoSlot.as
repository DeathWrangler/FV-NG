package Widgets.Slots
{
   import Managers.GuildManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildLogoSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_highLightButton:FarmButton;
      
      private var m_highLigtMc:MovieClip;
      
      public function GuildLogoSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         (m_element as MovieClip).visible = true;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.index;
         var icon:FarmIcon = new FarmIcon(m_element["icon_mc"] as MovieClip,this.m_data.image);
         icon.setIconSize(50,50);
         icon.visible = true;
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_highLightButton = new FarmButton(m_element["icon_mc"],this.onClick);
            this.m_highLightButton.visible = true;
         }
         this.m_highLigtMc = m_element["highlight_mc"] as MovieClip;
         this.m_highLigtMc.visible = false;
      }
      
      public function onClick(e:Event) : void
      {
         GuildManager.getInstance().setImageId(this.m_slotIndex);
         if(GuildManager.getInstance().m_guildCreateWindow)
         {
            GuildManager.getInstance().m_guildCreateWindow.clearHighlight();
         }
         if(GuildManager.getInstance().m_guildEditWindow)
         {
            GuildManager.getInstance().m_guildEditWindow.clearHighlight();
         }
         this.m_highLigtMc.visible = true;
      }
      
      public function set highlight(setValue:Boolean) : void
      {
         this.m_highLigtMc.visible = setValue;
      }
   }
}

