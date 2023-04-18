#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t* state, unsigned int snum);
static char next_square(game_state_t* state, unsigned int snum);
static void update_tail(game_state_t* state, unsigned int snum);
static void update_head(game_state_t* state, unsigned int snum);

/* Task 1 */
//黑板有18行，每行有20列。果实在第2行第9列(零索引)。尾部在第2行，第2列，头部在第2行，第4列。

game_state_t* create_default_state() {
  // TODO: Implement this function.
  game_state_t* default_state = malloc(sizeof(game_state_t));

  // initial num_rows;
  default_state->num_rows = 18;

  // initial board
  default_state->board = malloc(18 * sizeof(char*));
  for (int i = 0; i < 18; i++)
  {
    default_state->board[i] = malloc(21 * sizeof(char));
  }

  strcpy(default_state->board[0],"####################");
  strcpy(default_state->board[17],"####################");
  strcpy(default_state->board[2],"# d>D    *         #");

  for (int i = 1; i < 17; i++)
  {
    if (i!= 2)
    {
      strcpy(default_state->board[i],"#                  #");
    }
    
  }

  // initial num_snakes
  default_state->num_snakes = 1;

  // initial snakes
  default_state->snakes = malloc(sizeof(snake_t));
  
  default_state->snakes->head_col = 4;
  default_state->snakes->head_row = 2;

  default_state->snakes->tail_col = 2;
  default_state->snakes->tail_row = 2;

  default_state->snakes->live = true;
  
  return default_state;
}

/* Task 2 */
void free_state(game_state_t* state) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_rows; i++)
  {
    free(state->board[i]);
  }
  free(state->board);
  free(state->snakes);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  // TODO: Implement this function.
  for(int i = 0; i < state->num_rows; i++){
    fprintf(fp,"%s\n",state->board[i]);
  }
  return;
}

/*  
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t* state, unsigned int row, unsigned int col) {
  return state->board[row][col];
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  if (c == 'w' || c == 'a' || c == 's' || c == 'd')
  {
    return true;
  }
  
  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  if (c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x')
  {
    return true;
  }
  
  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  char letters[] = "wasd^<v>WASDx";
  for (int i = 0; i < 13; i += 1) {
    if (c == letters[i]) {
      return true;
    }
  }
  return false;
}

static bool is_wall(char c){
  if (c == '#') return true;
  return false;
}

static bool is_fruit(char c){
  if (c == '*') return true;
  return false;
}
/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  if (c == '^') c = 'w';
  if (c == 'v') c = 's';
  if (c == '<') c = 'a';
  if (c == '>') c = 'd';

  return c;
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  if (c == 'W') c = '^';
  if (c == 'S') c = 'v';
  if (c == 'A') c = '<';
  if (c == 'D') c = '>';

  return c;
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's' || c == 'S')
  {
    return cur_row + 1;
  }

  else if (c == '^' || c == 'w' || c == 'W'){
    return cur_row -1;
  }

  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  if (c == '>' || c == 'd' || c == 'D')
  {
    return cur_col + 1;
  }

  else if (c == '<' || c == 'a' || c == 'A'){
    return cur_col - 1;
  }

  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/

static char next_square(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.

  unsigned int headrow = state->snakes[snum].head_row;
  unsigned int headcol = state->snakes[snum].head_col;
  char c = get_board_at(state,headrow,headcol);

  unsigned int next_col = get_next_col(headcol,c);
  unsigned int next_row = get_next_row(headrow,c);
  return get_board_at(state,next_row,next_col);
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  
  unsigned int headrow = state->snakes[snum].head_row;
  unsigned int headcol = state->snakes[snum].head_col;
  // printf("state:282 %d %d\n",headrow,headcol);
  char head = get_board_at(state,headrow,headcol);
  // printf("%c\n",head);
  unsigned int next_col = get_next_col(headcol,head);
  unsigned int next_row = get_next_row(headrow,head);
  // change the board

  // 1. set head
  set_board_at(state,next_row,next_col,head);
  // printf("set head of %d it is on the %d %d\n",snum,next_row,next_col);
  /**for (unsigned int i = 0; i < state->num_rows; i++) {
      for (unsigned int j = 0; j < strlen(state->board[i]); j++) {
        printf("%c", state->board[i][j]);
      }
      printf("\n");
    }
 **/
  //2. change body
  char tmp = head_to_body(head);
  // printf("tmp : %c\n",tmp);
  set_board_at(state,headrow,headcol,tmp);
  /**for (unsigned int i = 0; i < state->num_rows; i++) {
      for (unsigned int j = 0; j < strlen(state->board[i]); j++) {
        printf("%c", state->board[i][j]);
      }
      printf("\n");
    }
**/
  // change the snake
  state->snakes[snum].head_col = next_col;
  state->snakes[snum].head_row = next_row;
  
  return;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  if (!state->snakes[snum].live)
  {
    return;
  }
  
  unsigned int tailrow = state->snakes[snum].tail_row;
  unsigned int tailcol = state->snakes[snum].tail_col;
  char tail = get_board_at(state,tailrow,tailcol);
  unsigned int next_col = get_next_col(tailcol,tail);
  unsigned int next_row = get_next_row(tailrow,tail);
  // change the board

  // 1. set tail
  char new_tail = body_to_tail(get_board_at(state,next_row,next_col));
  set_board_at(state,next_row,next_col,new_tail);

  //2. change body
  set_board_at(state,tailrow,tailcol,' ');

  // change the snake
  state->snakes[snum].tail_col = next_col;
  state->snakes[snum].tail_row = next_row;
  return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_snakes; i++)
  {
    // printf("we are update the %dth snake\n",i);
    if (!state->snakes[i].live)
    {
      continue;
    }
    
    unsigned int headrow = state->snakes[i].head_row;
    unsigned int headcol = state->snakes[i].head_col;
    char next_char = next_square(state,i);

    // 如果头部撞到了蛇或者墙上.
    if (is_snake(next_char) || is_wall(next_char))
    {
      set_board_at(state,headrow,headcol,'x');
      state->snakes[i].live = false;
    }
    
    //如果蛇头移动到一个水果中
    else if (is_fruit(next_char))
    {
      update_head(state,i);
      add_food(state);
    }
    else { 
      update_head(state,i);
      update_tail(state,i);
    }
  }
  return;
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  // TODO: Implement this function.
  
  game_state_t* state = malloc(sizeof(game_state_t));
  FILE* f = fopen(filename,"r");

  // check the file
  if (f == NULL) {
    free(state);
    exit(-1);
  }

  // get the num of rows.
  char c;
  unsigned int num_rows = 0;
  while (!feof(f)) {
    c = fgetc(f);
    if (c == '\n') {
      num_rows++;
    }
  } 
  
  // set state
  state->num_rows = num_rows;
  state->board = malloc(num_rows * sizeof(char*));

  rewind(f);
  char str[1000000];
  for (int i = 0; fgets(str,1000000,f); i++)
  {
    state->board[i] = malloc((strlen(str) + 1) * sizeof(char));
    strcpy(state->board[i], str);
    state->board[i][strlen(str) - 1] = '\0';
  }
  
  fclose(f);
  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int index = 0;
  unsigned int headrow = 0;
  unsigned int headcol = 0;
  while (true){
    for (unsigned int i = 0; i < state->num_rows; i++)
    {
      for(unsigned int j = 0; j < strlen(state->board[i]); j++){
          //printf("437: we run here and the cols is %d\n",strlen(state->board[i]));
        char tmp = get_board_at(state,i,j);
        if (!is_snake(tmp))
        {
          continue;
        }
        if (is_head(tmp))
        {
          //printf("444: we run here\n");
          headrow = i;
          headcol = j;
          if (index == snum)
          {
            goto here;
          }
          index ++;
        }
      }
    }
  }
  here:
  state->snakes[snum].head_row = headrow;
  state->snakes[snum].head_col = headcol;
  return;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  // TODO: Implement this function.

  unsigned int num = 0;
  unsigned int tail_row[100000];
  unsigned int tail_col[100000];
  // find、set tail and get the num of snakes
  for (unsigned int i = 0; i < state->num_rows; i++)
    {
      for(unsigned int j = 0; j < strlen(state->board[i]); j++){
        char tmp = get_board_at(state,i,j);
        if (is_tail(tmp))
        {
          tail_row[num]= i;
          tail_col[num]= j;
          num ++;
        }
      }
    }

  state->snakes = malloc(num * sizeof(snake_t));
  state->num_snakes = num;

  for (int i = 0; i < num; i++)
  {
    state->snakes[i].tail_row = tail_row[i];
    state->snakes[i].tail_col = tail_col[i];
    state->snakes[i].live = true;
    find_head(state,i);
    //printf("snake %d headcol is %d head row is %d tail row is %d tail col is %d\n",i,state->snakes[i].head_col,state->snakes[i].head_row,state->snakes[i].tail_row,state->snakes[i].tail_col);
  }
  return state;
}
