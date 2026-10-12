package Widgets.Slots
{
   import Managers.TwentiesInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class TwentiesInnovationLeaderboardSlot extends ZwSlotFrame
   {
      
      protected var m_leaderboardName:String;
      
      protected var m_highlightMc:MovieClip;
      
      protected var m_score:ZwTextField;
      
      protected var m_rank:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      protected var m_name:ZwTextField;
      
      protected var m_bg:MovieClip;
      
      public function TwentiesInnovationLeaderboardSlot(element:DisplayObject, parentWindow:FarmWindow, leaderboardName:String)
      {
         super(element);
         this.m_leaderboardName = leaderboardName;
         if(m_element.number_tf != null)
         {
            addWidget(this.m_rank = new ZwTextField(m_element.number_tf),false);
         }
         if(m_element.name_tf != null)
         {
            addWidget(this.m_name = new ZwTextField(m_element.name_tf),false);
         }
         if(m_element.score_tf != null)
         {
            addWidget(this.m_score = new ZwTextField(m_element.score_tf),false);
         }
         if(m_element.icon_mc != null)
         {
            addWidget(this.m_icon = new FarmIcon(m_element.icon_mc),false);
         }
         if(m_element.mc_highlight != null)
         {
            this.m_highlightMc = m_element.mc_highlight as MovieClip;
         }
         if(m_element.mc_cell_bg != null)
         {
            this.m_bg = m_element.mc_cell_bg as MovieClip;
         }
      }
      
      private function get manager() : TwentiesInnovationManager
      {
         return TwentiesInnovationManager.getInstance();
      }
      
      override public function populate(data:Object) : void
      {
         var zid:String = null;
         super.populate(data);
         if(data != null)
         {
            if(this.m_rank != null)
            {
               this.m_rank.visible = true;
               if(data["value"] <= 0)
               {
                  this.m_rank.text = "-";
               }
               else
               {
                  this.m_rank.text = data["rank"];
               }
            }
            if(this.m_name != null)
            {
               this.m_name.visible = true;
               this.m_name.text = data["name"];
            }
            if(this.m_score != null)
            {
               this.m_score.visible = true;
               if(data["value"] <= 0)
               {
                  this.m_score.text = "-";
               }
               else
               {
                  this.m_score.text = data["value"];
               }
            }
            if(this.m_icon != null)
            {
               this.m_icon.visible = true;
               this.m_icon.loadIcon(data["icon"]);
               if(data["rank"] < 4)
               {
                  this.m_icon.setIconSize(70,70);
               }
               else
               {
                  this.m_icon.setIconSize(25,25);
               }
               this.m_icon.setSmoothing(true);
            }
            if(this.m_bg != null)
            {
               this.m_bg.visible = true;
            }
            zid = this.manager.getUserZid();
            if(data["zid"] == zid)
            {
               this.m_highlightMc.visible = true;
            }
            else
            {
               this.m_highlightMc.visible = false;
            }
         }
      }
   }
}

