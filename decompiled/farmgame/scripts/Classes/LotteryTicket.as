package Classes
{
   public class LotteryTicket
   {
      
      public static const LOTTERY_TICKET_NO_DATA:Number = -1;
      
      public static const LIMIT_NUM_BALLS:Number = 4;
      
      private var m_timestamp:Number = 0;
      
      private var m_ticketData:Object = null;
      
      private var m_numbers:Object = null;
      
      private var m_redeemed:Boolean = false;
      
      private var m_state:String = "";
      
      private var m_winnings:Number = -1;
      
      public function LotteryTicket(value:Object)
      {
         super();
         this.m_ticketData = value;
         if(value.hasOwnProperty("numbers"))
         {
            this.m_numbers = value["numbers"];
         }
         if(value.hasOwnProperty("redeemed"))
         {
            this.m_redeemed = value["redeemed"];
         }
         if(value.hasOwnProperty("time"))
         {
            this.m_timestamp = value["time"];
         }
      }
      
      public function get timestamp() : Number
      {
         return this.m_timestamp;
      }
      
      public function get redeemed() : Boolean
      {
         return this.m_redeemed;
      }
      
      public function get numbers() : Object
      {
         return this.m_numbers;
      }
      
      public function get ticketData() : Object
      {
         return this.m_ticketData;
      }
      
      public function get winningNumbers() : Number
      {
         return this.m_winnings;
      }
      
      public function get currentState() : String
      {
         return this.m_state;
      }
      
      public function set currentState(value:String) : void
      {
         this.m_state = value;
      }
      
      public function set winningNumbers(valueWon:Number) : void
      {
         this.m_winnings = valueWon;
      }
      
      public function set ticketData(value:Object) : void
      {
         this.m_ticketData = value;
      }
   }
}

