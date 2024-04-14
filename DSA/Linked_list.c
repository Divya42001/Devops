#include<stdio.h>
#include<stdlib.h>
void main()
{
    struct node
    {
      int data;
      struct node* next};
    struct node* newnode,*temp,* head;
    head=0;
    int choice;
    while (choice)
    {
        newnode=(struct node*)(malloc(sizeof(struct node*)));
        printf("Enter data");
        scanf("%d",&newnode->data);
        newnode->next=0;
        if (head==0)
        {
            head=temp=newnode;
        }
        else
        {
            temp->next=newnode;
            temp=newnode;
        }
        printf("Do you want to continue");
        scanf("%d",&choice);   
    }
     temp=head;
    while (temp!=0)
    {
        printf("%d\n",temp->data);
        temp=temp->next;
    }
}