package Widgets.Windows.MOTD
{
   import Managers.FishingV2Manager;
   import Managers.ItemFinderManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FishingV2WaterTileMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private static const START_DATE:String = "Aug 31st 2015";
      
      protected var m_learnMoreLink:ZwButton;
      
      private var m_content:ZwFrame;
      
      private const TILE_NAME:String = "xcl_rubbletreasure_payer12";
      
      public function FishingV2WaterTileMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var tileUnlock:* = FishingV2Manager.getInstance().isP12TileUnlocked();
         if(Boolean(m_window) && m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.accept_bt)
            {
               if(tileUnlock)
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Great!",this.onAccept));
               }
               else
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Let\'s Go",this.onHighlihtTile));
               }
            }
            if(m_window.mainWindow.hasOwnProperty("close_bt"))
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
               m_window.mainWindow.close_bt.visible = false;
            }
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,"Fishing Frenzy!"));
            }
            if(m_window.mainWindow.body_tf)
            {
               if(tileUnlock)
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body_tf,"You have fishing access to the Smoothie Pond!"));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body_tf,"There are a lot of Rare fishes in Smoothie Pond!"));
               }
            }
            if(m_window.mainWindow.body2_tf)
            {
               if(tileUnlock)
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body2_tf,"You now have double the chance of catching a Rare fish! Make sure you use the correct Rod!"));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body2_tf,"Unlock Smoothie Pond to access this pond and double your chances of getting a Rare fish!"));
               }
            }
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.close();
      }
      
      public function onHighlihtTile(event:Event) : void
      {
         ItemFinderManager.getInstance().highlightWorldItems(this.TILE_NAME);
         this.close();
      }
   }
}

